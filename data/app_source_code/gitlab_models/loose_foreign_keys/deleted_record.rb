# frozen_string_literal: true

class LooseForeignKeys::DeletedRecord < Gitlab::Database::SharedModel
  PARTITION_DURATION = 1.day

  include PartitionedTable

  self.primary_key = :id
  self.ignored_columns = %i[partition]

  partitioned_by :partition, strategy: :sliding_list,
                             next_partition_if: -> (active_partition) do
                                                  oldest_record_in_partition = LooseForeignKeys::DeletedRecord
                                                    .select(:id, :created_at)
                                                    .for_partition(active_partition.value)
                                                    .order(:id)
                                                    .limit(1)
                                                    .take

                                                  oldest_record_in_partition.present? &&
                                                    oldest_record_in_partition.created_at < PARTITION_DURATION.ago
                                                end,
                             detach_partition_if: -> (partition) do
                                                    !LooseForeignKeys::DeletedRecord
                                                      .for_partition(partition.value)
                                                      .status_pending
                                                      .exists?
                                                  end

  scope :for_table, -> (table) { where(fully_qualified_table_name: table) }
  scope :for_partition, -> (partition) { where(partition: partition) }
  scope :consume_order, -> { order(:partition, :consume_after, :id) }

  enum status: { pending: 1, processed: 2 }, _prefix: :status

  def self.load_batch_for_table(table, batch_size)
    # selecting partition as partition_number to workaround the sliding partitioning column ignore
    select(arel_table[Arel.star], arel_table[:partition].as('partition_number'))
      .for_table(table)
      .status_pending
      .consume_order
      .limit(batch_size)
      .to_a
  end

  def self.mark_records_processed(records)
    update_by_partition(records) do |partitioned_scope|
      partitioned_scope.update_all(status: :processed)
    end
  end

  def self.reschedule(records, consume_after)
    update_by_partition(records) do |partitioned_scope|
      partitioned_scope.update_all(consume_after: consume_after, cleanup_attempts: 0)
    end
  end

  def self.increment_attempts(records)
    update_by_partition(records) do |partitioned_scope|
      # Naive incrementing of the cleanup_attempts is good enough for us.
      partitioned_scope.update_all('cleanup_attempts = cleanup_attempts + 1')
    end
  end

  def self.update_by_partition(records)
    update_count = 0

    # Run a query for each partition to optimize the row lookup by primary key (partition, id)
    records.group_by(&:partition_number).each do |partition, records_within_partition|
      partitioned_scope = status_pending
        .for_partition(partition)
        .where(id: records_within_partition.pluck(:id))

      update_count += yield(partitioned_scope)
    end

    update_count
  end

  private_class_method :update_by_partition
end

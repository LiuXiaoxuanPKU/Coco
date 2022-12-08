# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    class StageEventHash < ApplicationRecord
      has_many :cycle_analytics_project_stages, class_name: 'Analytics::CycleAnalytics::ProjectStage', inverse_of: :stage_event_hash

      validates :hash_sha256, presence: true

      # Creates or queries the id of the corresponding stage event hash code
      def self.record_id_by_hash_sha256(hash)
        casted_hash_code = Arel::Nodes.build_quoted(hash, Analytics::CycleAnalytics::StageEventHash.arel_table[:hash_sha256]).to_sql

        # Atomic, safe insert without retrying
        query = <<~SQL
        WITH insert_cte AS #{Gitlab::Database::AsWithMaterialized.materialized_if_supported} (
          INSERT INTO #{quoted_table_name} (hash_sha256) VALUES (#{casted_hash_code}) ON CONFLICT DO NOTHING RETURNING ID
        )
        SELECT ids.id FROM (
          (SELECT id FROM #{quoted_table_name} WHERE hash_sha256=#{casted_hash_code} LIMIT 1)
            UNION ALL
          (SELECT id FROM insert_cte LIMIT 1)
        ) AS ids LIMIT 1
        SQL

        connection.execute(query).first['id']
      end

      def self.cleanup_if_unused(id)
        unused_hashes_for(id)
          .where(id: id)
          .delete_all
      end

      def self.unused_hashes_for(id)
        exists_query = Analytics::CycleAnalytics::ProjectStage.where(stage_event_hash_id: id).select('1').limit(1)
        where.not('EXISTS (?)', exists_query)
      end
    end
  end
end
Analytics::CycleAnalytics::StageEventHash.prepend_mod_with('Analytics::CycleAnalytics::StageEventHash')

module RecurringTodos
  class MonthlyRecurringTodosBuilder < AbstractRecurringTodosBuilder
    attr_reader :recurring_todo

    def initialize(user, attributes)
      super(user, attributes, MonthlyRecurrencePattern)
    end

    def attributes_to_filter
      %w{
        monthly_selector       monthly_every_x_day   monthly_every_x_month
        monthly_every_x_month2 monthly_every_xth_day monthly_day_of_week
      }
    end

    def map_attributes(mapping)
      mapping = map(mapping, :every_other1, 'monthly_every_x_day')
      mapping = map(mapping, :every_other3, 'monthly_every_xth_day')
      mapping = map(mapping, :every_count,  'monthly_day_of_week')

      mapping.set(:recurrence_selector, get_recurrence_selector)

      mapping.set(:every_other2, mapping.get(get_every_other2))
      mapping.except('monthly_every_x_month').except('monthly_every_x_month2')
    end

    def get_recurrence_selector
      @selector == 'monthly_every_x_day' ? 0 : 1
    end

    def get_every_other2
      get_recurrence_selector == 0 ? 'monthly_every_x_month' : 'monthly_every_x_month2'
    end

    def selector_key
      :monthly_selector
    end

    def valid_selector?(selector)
      %w{monthly_every_x_day monthly_every_xth_day}.include?(selector)
    end
  end
end

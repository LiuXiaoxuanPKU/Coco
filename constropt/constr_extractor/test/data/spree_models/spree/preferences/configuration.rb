# This takes the preferable methods and adds some
# syntactic sugar to access the preferences
#
# class App < Configuration
#   preference :color, :string
# end
#
# a = App.new
#
# setters:
# a.color = :blue
# a[:color] = :blue
# a.set :color = :blue
# a.preferred_color = :blue
#
# getters:
# a.color
# a[:color]
# a.get :color
# a.preferred_color
#
#
module Spree::Preferences
  class Configuration
    include Spree::Preferences::Preferable

    def configure
      yield(self) if block_given?
    end

    def preferences
      ::Spree::Preferences::ScopedStore.new(self.class.name.underscore)
    end

    def reset
      preferences.each do |name, _value|
        set_preference name, preference_default(name)
      end
    end

    alias [] get_preference
    alias []= set_preference

    alias get get_preference

    def set(*args)
      options = args.extract_options!
      options.each do |name, value|
        set_preference name, value
      end

      set_preference args[0], args[1] if args.size == 2
    end

    def method_missing(method, *args)
      name = method.to_s.delete('=')
      if has_preference? name
        if method.to_s =~ /=$/
          set_preference(name, args.first)
        else
          get_preference name
        end
      else
        super
      end
    end
  end
end

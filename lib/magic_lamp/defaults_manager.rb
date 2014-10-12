module MagicLamp
  class DefaultsManager
    attr_accessor :configuration, :defaults, :parent

    def initialize(configuration, defaults, parent = nil)
      self.configuration = configuration
      self.defaults = defaults
      self.parent = parent
    end

    def branch(defaults_managers = [self])
      ancestor = defaults_managers.first.parent
      if ancestor.nil?
        defaults_managers
      else
        branch([ancestor, *defaults_managers])
      end
    end

    def all_defaults
      [configuration.global_defaults, *branch.map(&:defaults)]
    end

    def merged_defaults
      all_defaults.each_with_object({}) do |defaults, merged_defaults_hash|
        merged_defaults_hash.merge!(defaults)
      end
    end

    def define(new_defaults, &block)
      new_manager = self.class.new(configuration, new_defaults, self)
      block.call(new_manager)
    end
  end
end

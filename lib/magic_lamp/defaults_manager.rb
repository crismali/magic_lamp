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

    def merge_with_defaults(settings)
      merged_defaults = all_defaults.each_with_object({}) do |defaults, merged_defaults_hash|
        merged_defaults_hash.merge!(defaults)
      end
      merged_defaults.merge(settings)
    end

    def define(new_defaults, &block)
      raise ArgumentError, "`#{__method__}` requires a block" if block.nil?
      new_manager = self.class.new(configuration, new_defaults, self)
      block.call(new_manager)
    end

    def register_fixture(options, &block)
      merged_options = merge_with_defaults(options)
      MagicLamp.register_fixture(merged_options, &block)
    end

    REGISTER_FIXTURE_ALIASES.each do |method_name|
      alias_method method_name, :register_fixture
    end
  end
end

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

    def all_defaults(settings)
      [configuration.global_defaults, *branch.map(&:defaults), settings]
    end

    def merge_with_defaults(settings)
      all_defaults(settings).each_with_object({}) do |defaults, merged_defaults_hash|
        defaults_namespace = defaults[:namespace] || defaults[:controller].try(:controller_name)
        extensions = Array(merged_defaults_hash[:extend]) + Array(defaults[:extend])
        namespace = [merged_defaults_hash[:namespace], defaults_namespace].select(&:present?).join(FORWARD_SLASH)
        merged_defaults_hash.merge!(defaults)
        merged_defaults_hash[:namespace] = namespace if namespace.present?
        merged_defaults_hash[:extend] = extensions
      end
    end

    def define(new_defaults = {}, &block)
      raise ArgumentError, "`#{__method__}` requires a block" if block.nil?
      new_manager = self.class.new(configuration, new_defaults, self)
      block.call(new_manager)
    end

    def register_fixture(options = {}, &block)
      merged_options = merge_with_defaults(options)
      MagicLamp.register_fixture(merged_options, &block)
    end

    REGISTER_FIXTURE_ALIASES.each do |method_name|
      alias_method method_name, :register_fixture
    end
  end
end

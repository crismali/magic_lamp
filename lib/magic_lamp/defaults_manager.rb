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
  end
end

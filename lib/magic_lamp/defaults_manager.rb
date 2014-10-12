module MagicLamp
  class DefaultsManager
    attr_accessor :configuration, :defaults, :parent

    def initialize(configuration, defaults, parent = nil)
      self.configuration = configuration
      self.defaults = defaults
      self.parent = parent
    end
  end
end

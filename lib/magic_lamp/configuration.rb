module MagicLamp
  class Configuration
    attr_accessor :after_each_proc, :before_each_proc, :infer_names

    def initialize
      self.infer_names = true
    end

    def before_each(&block)
      register_callback(:before, block)
    end

    def after_each(&block)
      register_callback(:after, block)
    end

    private

    def register_callback(type, block)
      if block.nil?
        raise ArgumentError, "MagicLamp.configuration##{type}_each requires a block"
      end
      send("#{type}_each_proc=", block)
    end
  end
end

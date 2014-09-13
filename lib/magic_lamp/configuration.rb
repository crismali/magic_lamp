module MagicLamp
  class Configuration
    attr_accessor :before_each_proc, :after_each_proc

    def before_each(&block)
      register_callback(:before, block)
    end

    def after_each(&block)
      register_callback(:after, block)
    end

    private

    def register_callback(type, block)
      if block.nil?
        raise ArgumentError, "MagicLamp##{type}_each requires a block"
      end
      send("#{type}_each_proc=", block)
    end
  end
end

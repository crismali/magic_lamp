# frozen_string_literal: true

module MagicLamp
  module Callbacks
    attr_accessor :configuration

    def initialize(configuration)
      self.configuration = configuration
    end

    def execute_before_each_callback
      execute_callback(:before)
    end

    def execute_after_each_callback
      execute_callback(:after)
    end

    def execute_callbacks_around(&block)
      if block.nil?
        raise ArgumentError, "#{self.class.name}##{__method__} requires a block"
      end

      execute_before_each_callback
      value = yield
      execute_after_each_callback
      value
    end

    private

    def execute_callback(type)
      callback = configuration.send("#{type}_each_proc")
      callback.call if callback
    end
  end
end

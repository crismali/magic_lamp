module MagicLamp
  module Helpers
    def namespace
      MagicLamp
    end

    def execute_before_each_callback
      namespace.before_each_proc.call unless namespace.before_each_proc.nil?
    end

    def execute_after_each_callback
      namespace.after_each_proc.call unless namespace.after_each_proc.nil?
    end
  end
end

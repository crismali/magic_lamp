module MagicLamp
  class RenderCatcher
    include Callbacks

    attr_accessor :render_argument

    def render(first_arg, *args)
      self.render_argument = first_arg
    end

    def first_render_argument(&block)
      execute_before_each_callback
      instance_eval(&block)
      execute_after_each_callback
      render_argument
    end

    def method_missing(method, *args, &block)
      self
    end
  end
end

module MagicLamp
  class RenderCatcher
    attr_accessor :render_argument

    def namespace
      MagicLamp
    end

    def render(first_arg, *args)
      self.render_argument = first_arg
    end

    def first_render_argument(&block)
      instance_eval(&block)
      render_argument
    end

    def method_missing(method, *args, &block)
    end
  end
end

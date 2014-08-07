class RenderCatcher
  attr_accessor :render_arguments

  def render(*args)
    self.render_arguments = args
  end

  def catch_render_arguments(&block)
    instance_eval(&block)
    render_arguments
  end

  def method_missing(method, *args, &block)
  end
end

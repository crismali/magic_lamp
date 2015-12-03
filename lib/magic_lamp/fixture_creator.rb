module MagicLamp
  class FixtureCreator
    include Callbacks

    attr_accessor :render_arguments

    def generate_template(controller_class, extensions, &block)
      fixture = execute_callbacks_around do
        controller = new_controller(controller_class, extensions, &block)
        controller.request.env["action_dispatch.request.path_parameters"] = { action: "index", controller: controller.controller_name }
        fetch_rendered(controller, block)
      end

      if fixture.empty?
        raise EmptyFixtureError, "Fixture was an empty string. This is probably not what you meant to have happen."
      end

      fixture
    end

    def new_controller(controller_class, extensions, &block)
      controller = controller_class.new
      redefine_view_context(controller, extensions)
      extensions.each { |extension| controller.extend(extension) }
      controller.request = ActionDispatch::TestRequest.new
      redefine_redirect_to(controller)
      redefine_render(controller)
      controller
    end

    def munge_arguments(arguments)
      first_arg, second_arg = arguments

      if first_arg.is_a?(Hash)
        first_arg[:layout] ||= false
      elsif second_arg.is_a?(Hash)
        second_arg[:layout] ||= false
      else
        arguments << { layout: false }
      end
      arguments
    end

    private

    def fetch_rendered(controller, block)
      value = controller.instance_eval(&block)
      json_value = fetch_json_value
      if json_value
        convert_to_json(json_value)
      elsif render_arguments
        munged_arguments = munge_arguments(render_arguments)
        controller.render_to_string(*munged_arguments)
      else
        convert_to_json(value)
      end
    end

    def fetch_json_value
      render_arg = render_arguments.try(:first)
      render_arg[:json] if render_arg.try(:key?, :json)
    end

    def convert_to_json(value)
      if value.is_a?(String)
        value
      else
        value.to_json
      end
    end

    def redefine_view_context(controller, extensions)
      controller.singleton_class.send(:define_method, :view_context) do |*args, &block|
        view_context = super(*args, &block)
        extensions.each { |extension| view_context.extend(extension) }
        view_context
      end
    end

    def redefine_render(controller)
      fixture_creator = self
      already_called = false
      controller.singleton_class.send(:define_method, :render) do |*args|
        if already_called
          raise DoubleRenderError, "called `render` twice, this is probably not what you want to have happen."
        end
        already_called = true
        fixture_creator.render_arguments = args
      end
    end

    def redefine_redirect_to(controller)
      controller.singleton_class.send(:define_method, :redirect_to) do |*args|
        raise AttemptedRedirectError, "called `redirect_to` while creating a fixture, this is probably not what you want to have happen."
      end
    end
  end
end

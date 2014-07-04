require "fileutils"

module MagicLamp
  class FixtureCreator
    attr_accessor :render_arguments, :namespace

    def initialize
      self.namespace = MagicLamp
    end

    def create_fixture(fixture_name, controller_class, &block)
      File.open(fixture_path(fixture_name), "w") do |file|
        controller = new_controller(controller_class, &block)
        munged_arguments = munge_arguments(render_arguments)
        template = controller.render_to_string(*munged_arguments)
        file.write(template)
      end
    end

    def new_controller(controller_class, &block)
      controller = controller_class.new
      controller.request = ActionDispatch::TestRequest.new
      redefine_render(controller)
      controller.instance_eval(&block)
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

    def redefine_render(controller)
      fixture_creator = self
      controller.singleton_class.send(:define_method, :render) do |*args|
        fixture_creator.render_arguments = args
      end
    end

    def fixture_path(fixture_name)
      namespace.tmp_path.join("#{fixture_name}.html")
    end
  end
end

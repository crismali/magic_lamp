require "fileutils"

module MagicLamp
  class FixtureCreator
    MAGIC_LAMP = "magic_lamp"
    DEFAULT_PATH = ["spec", MAGIC_LAMP]
    TMP_PATH = ["tmp", MAGIC_LAMP]

    attr_accessor :render_arguments
    attr_writer :path

    def path
      path = @path || DEFAULT_PATH
      Rails.root.join(*path)
    end

    def tmp_path
      Rails.root.join(*TMP_PATH)
    end

    def create_tmp_directory
      FileUtils.mkdir_p(tmp_path)
    end

    def remove_tmp_directory
      FileUtils.rm_rf(tmp_path)
    end

    def create_fixture(fixture_name, controller_class, &block)
      create_tmp_directory

      File.open(fixture_path(fixture_name), "w") do |file|
        file.write("hey")
      end
    end

    def new_controller(controller_class)
      controller = controller_class.new
      controller.request = ActionDispatch::TestRequest.new
      redefine_render(controller)
      controller
    end

    def munge_arguments(arguments)
      if arguments.first.is_a?(Hash)
        arguments.first[:layout] ||= false
      elsif arguments.last.is_a?(Hash)
        arguments.last[:layout] ||= false
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
      tmp_path.join("#{fixture_name}.html")
    end
  end
end

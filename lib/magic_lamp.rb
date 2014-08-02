require "magic_lamp/fixture_creator"
require "magic_lamp/render_catcher"
require "magic_lamp/engine"

module MagicLamp
  LAMP = "_lamp"
  SPEC = "spec"
  STARS = "**"
  TEST = "test"

  class AmbiguousFixtureNameError < StandardError
  end

  class UnregisteredFixtureError < StandardError
  end

  class << self
    attr_accessor :registered_fixtures

    def path
      Rails.root.join(directory_path)
    end

    def register_fixture(controller_class = ::ApplicationController, fixture_name = nil, &block)
      if block.nil?
        raise ArgumentError, "MagicLamp#register_fixture requires a block"
      end

      if fixture_name.nil?
        fixture_name = default_fixture_name(controller_class, fixture_name, block)
      end

      registered_fixtures[fixture_name] = [controller_class, block]
    end

    def registered?(fixture_name)
      registered_fixtures.key?(fixture_name)
    end

    def load_lamp_files
      self.registered_fixtures = {}
      load_all(Dir[path.join(STARS, "*#{LAMP}.rb")])
    end

    def generate_fixture(fixture_name)
      unless registered?(fixture_name)
        raise UnregisteredFixtureError, "'#{fixture_name}' is not a registered fixture"
      end
      controller_class, block = registered_fixtures[fixture_name]
      FixtureCreator.new.generate_template(controller_class, &block)
    end

    private

    def default_fixture_name(controller_class, fixture_name, block)
      first_arg = first_render_arg(block)
      fixture_name = template_name(first_arg).to_s
      if fixture_name.blank?
        raise AmbiguousFixtureNameError, "Unable to infer fixture name"
      end
      fixture_name = prepend_controller_name(fixture_name, controller_class)
      fixture_name
    end

    def first_render_arg(block)
      render_catcher = RenderCatcher.new
      render_catcher.instance_eval(&block)
      render_catcher.render_arguments.first
    end

    def template_name(render_arg)
      if render_arg.is_a?(Hash)
        render_arg[:template] || render_arg[:partial]
      else
        render_arg
      end
    end

    def prepend_controller_name(fixture_name, controller_class)
      controller_name = controller_class.controller_name
      if controller_name == "application"
        fixture_name
      else
        "#{controller_name}/#{fixture_name}"
      end
    end

    def directory_path
      Dir.exist?(Rails.root.join(SPEC)) ? SPEC : TEST
    end

    def load_all(files)
      files.each { |file| load file }
    end
  end
end

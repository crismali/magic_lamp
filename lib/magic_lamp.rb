require "magic_lamp/fixture_creator"
require "magic_lamp/render_catcher"
require "magic_lamp/engine"

module MagicLamp
  LAMP = "_lamp"
  SPEC = "spec"
  STARS = "**"
  TEST = "test"
  Genie = Engine

  class AmbiguousFixtureNameError < StandardError
  end

  class UnregisteredFixtureError < StandardError
  end

  class AlreadyRegisteredFixtureError < StandardError
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

      if registered?(fixture_name)
        raise AlreadyRegisteredFixtureError, "a fixture called '#{fixture_name}' has already been registered"
      end

      registered_fixtures[fixture_name] = [controller_class, block]
    end

    alias_method :rub, :register_fixture
    alias_method :wish, :register_fixture

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

    def generate_all_fixtures
      load_lamp_files
      registered_fixtures.each_with_object({}) do |(fixture_name, _), fixtures|
        fixtures[fixture_name] = generate_fixture(fixture_name)
      end
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
      render_catcher.first_render_argument(&block)
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

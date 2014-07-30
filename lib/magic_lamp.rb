module MagicLamp
  LAMP = "_lamp"
  MAGIC_LAMP = "magic#{LAMP}"
  SPEC = "spec"
  STARS = "**"
  TEST = "test"
  TMP = "tmp"
  TMP_PATH = [TMP, MAGIC_LAMP]

  class << self
    attr_accessor :registered_fixtures

    def path
      Rails.root.join(directory_path)
    end

    def register_fixture(controller_class = ApplicationController, fixture_name = nil, &block)
      raise "MagicLamp#register_fixture requires a block" if block.nil?
      if fixture_name.nil?
        fixture_name = default_fixture_name(controller_class, fixture_name, block)
      end
      registered_fixtures[fixture_name] = [controller_class, block]
    end

    def load_lamp_files
      self.registered_fixtures = {}
      load_all(Dir[path.join(STARS, "*#{LAMP}.rb")])
    end

    def generate_fixture(fixture_name)
      load_lamp_files
      unless registered_fixtures.key?(fixture_name)
        raise "'#{fixture_name}' is not a registered fixture"
      end
      controller_class, block = registered_fixtures[fixture_name]
      FixtureCreator.new.generate_template(controller_class, &block)
    end

    def create_fixture(fixture_name, controller_class, &block)
      FixtureCreator.new.create_fixture(fixture_name, controller_class, &block)
    end

    def create_fixture_files
      create_tmp_directory
      load_lamp_files
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

    private

    def default_fixture_name(controller_class, fixture_name, block)
      first_arg = first_render_arg(block)
      fixture_name = template_name(first_arg).to_s
      raise "Unable to infer fixture name" if fixture_name.blank?
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

require "fileutils"
require "magic_lamp/fixture_creator"
require "magic_lamp/render_catcher"
require "tasks/magic_lamp_tasks"

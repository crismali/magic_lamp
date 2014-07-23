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

    def register_fixture(controller_class, fixture_name, &block)
      raise "MagicLamp#register_fixture requires a block" if block.nil?
      self.registered_fixtures[fixture_name] = [controller_class, block]
    end

    def create_fixture(fixture_name, controller_class, &block)
      FixtureCreator.new.create_fixture(fixture_name, controller_class, &block)
    end

    def load_lamp_files
      create_tmp_directory
      require_all(Dir[path.join(STARS, "*#{LAMP}.rb")])
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

    def directory_path
      Dir.exist?(Rails.root.join(SPEC)) ? SPEC : TEST
    end

    def require_all(files)
      files.each { |file| require file }
    end
  end

  self.registered_fixtures = {}
end

require "fileutils"
require "magic_lamp/fixture_creator"
require "tasks/magic_lamp_tasks"

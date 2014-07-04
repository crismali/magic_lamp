module MagicLamp
  LAMP = "_lamp"
  MAGIC_LAMP = "magic#{LAMP}"
  SPEC = "spec"
  STARS = "**"
  TEST = "test"
  TMP = "tmp"
  TMP_PATH = [TMP, MAGIC_LAMP]

  class << self
    attr_writer :path

    def path
      Rails.root.join(directory_path, MAGIC_LAMP)
    end

    def create_fixture(fixture_name, controller_class, &block)
      FixtureCreator.new.create_fixture(fixture_name, controller_class, &block)
    end

    def clear_fixtures
      FixtureCreator.new.remove_tmp_directory
    end

    def load_lamp_files
      require_all(Dir[path.join(STARS, "*#{LAMP}.rb")])
    end

    private

    def directory_path
      Dir.exist?(Rails.root.join(SPEC)) ? SPEC : TEST
    end

    def require_all(files)
      files.each { |file| require file }
    end
  end
end

require "magic_lamp/fixture_creator"
require "tasks/magic_lamp_tasks"

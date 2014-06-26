module MagicLamp
  MAGIC_LAMP = "magic_lamp"
  SPEC = "spec"
  TEST = "test"
  TMP = "tmp"
  TMP_PATH = [TMP, MAGIC_LAMP]

  class << self
    attr_writer :path

    def path
      path = @path || default_path
      Rails.root.join(*path)
    end

    def default_path
      [directory_path, MAGIC_LAMP]
    end

    def create_fixture(fixture_name, controller_class, &block)
      FixtureCreator.new.create_fixture(fixture_name, controller_class, &block)
    end

    def clear_fixtures
      FixtureCreator.new.remove_tmp_directory
    end

    def load_config
      Dir[Rails.root.join(directory_path, "**", "magic_lamp.rb")].each { |f| require f }
    end

    private

    def directory_path
      Dir.exist?(Rails.root.join(SPEC)) ? SPEC : TEST
    end
  end
end

require "magic_lamp/fixture_creator"

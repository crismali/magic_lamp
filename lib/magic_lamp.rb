module MagicLamp
  MAGIC_LAMP = "magic_lamp"
  DEFAULT_PATH = ["spec", MAGIC_LAMP]
  TMP_PATH = ["tmp", MAGIC_LAMP]

  class << self
    attr_writer :path

    def path
      path = @path || DEFAULT_PATH
      Rails.root.join(*path)
    end

    def create_fixture(fixture_name, controller_class, &block)
      FixtureCreator.new.create_fixture(fixture_name, controller_class, &block)
    end

    def clear_fixtures
      FixtureCreator.new.remove_tmp_directory
    end
  end
end

require "magic_lamp/fixture_creator"

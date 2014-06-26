module MagicLamp
  class << self
    def create_fixture(fixture_name, controller_class, &block)
      FixtureCreator.new.create_fixture(fixture_name, controller_class, &block)
    end

    def clear_fixtures
      FixtureCreator.new.remove_tmp_directory
    end
  end
end

require "magic_lamp/fixture_creator"

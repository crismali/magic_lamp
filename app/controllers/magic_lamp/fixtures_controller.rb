module MagicLamp
  class FixturesController < ApplicationController
    def show
      namespace.load_lamp_files
      render text: namespace.generate_fixture(params[:name])
    end

    def index
      namespace.load_lamp_files

      fixtures = namespace.registered_fixtures.each_with_object({}) do |(fixture_name, _), fixtures|
        fixtures[fixture_name] = namespace.generate_fixture(fixture_name)
      end
      render json: fixtures
    end

    private

    def namespace
      MagicLamp
    end
  end
end

module MagicLamp
  class FixturesController < ApplicationController
    def show
      namespace.load_lamp_files
      render text: namespace.generate_fixture(params[:name])
    end

    def index
      render json: namespace.generate_all_fixtures
    end

    private

    def namespace
      MagicLamp
    end
  end
end

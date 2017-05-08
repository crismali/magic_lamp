# frozen_string_literal: true

module MagicLamp
  class FixturesController < MagicLamp::ApplicationController
    ERRORS = [
      MagicLamp::ArgumentError,
      MagicLamp::AlreadyRegisteredFixtureError,
      MagicLamp::AmbiguousFixtureNameError,
      MagicLamp::UnregisteredFixtureError,
      MagicLamp::AttemptedRedirectError,
      MagicLamp::DoubleRenderError
    ].map(&:name)

    RENDER_TYPE = Rails::VERSION::MAJOR == 5 ? :plain : :text

    rescue_from(*ERRORS) do |exception, message = exception.message|
      error_message_with_bactrace = parse_error(exception, message)
      logger.error(error_message_with_bactrace)
      render RENDER_TYPE => message, status: 400
    end

    def show
      MagicLamp.load_lamp_files
      render RENDER_TYPE => MagicLamp.generate_fixture(params[:name])
    end

    def index
      render json: MagicLamp.generate_all_fixtures
    end

    private

    def parse_error(exception, message)
      ([message] + exception.backtrace).join("\n\s\s\s\s")
    end
  end
end

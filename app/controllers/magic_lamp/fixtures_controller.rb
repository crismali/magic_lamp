module MagicLamp
  class FixturesController < MagicLamp::ApplicationController
    ERRORS = [
      "MagicLamp::ArgumentError",
      "MagicLamp::AlreadyRegisteredFixtureError",
      "MagicLamp::AmbiguousFixtureNameError",
      "MagicLamp::UnregisteredFixtureError"
    ]

    rescue_from(*ERRORS) do |exception, message = exception.message|
      error_message_with_bactrace = parse_error(exception, message)
      logger.error(error_message_with_bactrace)
      render text: message, status: 400
    end

    def show
      namespace.load_lamp_files
      render text: namespace.generate_fixture(params[:name])
    end

    def index
      render json: namespace.generate_all_fixtures
    end

    private

    def parse_error(exception, message)
      ([message] + exception.backtrace).join("\n\s\s\s\s")
    end

    def namespace
      MagicLamp
    end
  end
end

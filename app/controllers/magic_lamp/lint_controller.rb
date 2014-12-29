module MagicLamp
  class LintController < MagicLamp::ApplicationController
    def index
      config_errors? && return
      errors = MagicLamp.lint_fixtures
      file_errors?(errors) && return
      fixture_errors?(errors) && return

      render :no_errors
    end

    private

    def file_errors?(errors)
      @file_errors = errors[:files]
      render :file_errors if @file_errors.present?
      @file_errors.present?
    end

    def fixture_errors?(errors)
      @fixture_errors = errors[:fixtures]
      render :fixture_errors if @fixture_errors.present?
      @fixture_errors.present?
    end

    def config_errors?
      @config_errors = MagicLamp.lint_config
      if @config_errors.present? && @config_errors[:config_file_load]
        render :config_file_load_error
      elsif @config_errors.present?
        render :callback_errors
      end
      @config_errors.present?
    end
  end
end

# frozen_string_literal: true

module MagicLamp
  APPLICATION = "application"
  APPLICATION_MATCHER = Regexp.compile("(\/#{APPLICATION}|#{APPLICATION}\/|#{APPLICATION})")
  EMPTY_STRING = ""
  FORWARD_SLASH = "/"
  LAMP = "_lamp"
  REGISTER_FIXTURE_ALIASES = %i[register fixture rub wish].freeze
  SPEC = "spec"
  STARS = "**"
  TEST = "test"
  Genie = Engine

  AlreadyRegisteredFixtureError = Class.new(StandardError)
  AmbiguousFixtureNameError = Class.new(StandardError)
  ArgumentError = Class.new(StandardError)
  AttemptedRedirectError = Class.new(StandardError)
  DoubleRenderError = Class.new(StandardError)
  EmptyFixtureError = Class.new(StandardError)
  UnregisteredFixtureError = Class.new(StandardError)
end

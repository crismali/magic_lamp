module MagicLamp
  APPLICATION = "application"
  APPLICATION_MATCHER = Regexp.compile("(\/#{APPLICATION}|#{APPLICATION}\/|#{APPLICATION})")
  EMPTY_STRING = ""
  FORWARD_SLASH = "/"
  LAMP = "_lamp"
  REGISTER_FIXTURE_ALIASES = [:register, :fixture, :rub, :wish]
  SPEC = "spec"
  STARS = "**"
  TEST = "test"
  Genie = Engine

  class AmbiguousFixtureNameError < StandardError
  end

  class UnregisteredFixtureError < StandardError
  end

  class AlreadyRegisteredFixtureError < StandardError
  end

  class ArgumentError < StandardError
  end
end

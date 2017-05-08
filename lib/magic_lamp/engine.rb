# frozen_string_literal: true

module MagicLamp
  class Engine < ::Rails::Engine
    isolate_namespace MagicLamp

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end

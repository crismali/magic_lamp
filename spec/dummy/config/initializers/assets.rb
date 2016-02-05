# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w(
  support/bind-poly.self.js
  magic_lamp/magic_lamp.self.js
  magic_lamp/genie.self.js
  magic_lamp/boot.self.js
  magic_lamp/application.self.js
  support/underscore-1.6.self.js
  support/chai.self.js
  support/chai-fuzzy.self.js
  support/sinon-chai.self.js
  support/sinon.self.js
  spec_helper.self.js
  genie_spec.self.js
  magic_lamp_spec.self.js
)

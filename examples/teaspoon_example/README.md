# MagicLamp/Teaspoon Example

## Setup
change `config.fixture_paths` from:
```ruby
config.fixture_paths = ["spec/javascripts/fixtures"]
```
to:
```ruby
config.fixture_paths = ["spec/javascripts/fixtures", "tmp/magic_lamp"]
```
in `spec/teaspoon_env.rb`.
## Illustration
Clone down this example app and `bundle`, then run `rake teaspoon`. There should be 1 failure. Next, run `rake magic_lamp:teaspoon`. Both tests should be passing.

## What's significant here
### Files
* `app/controllers/orders_controller` (its existence)
* `app/views/orders/index.html.erb` (the template we're making a fixture from)
* `spec/javascripts/magic_lamp.rb` (the fixture generating file)
* `spec/teaspoon_env.rb` (teaspoon config)

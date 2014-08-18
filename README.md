# MagicLamp

MagicLamp makes sure that your JavaScript tests break when you change a template your code depends on.

## Installation

Add this line to your application's Gemfile:

    gem "magic_lamp"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install magic_lamp
## Setup
### Ruby side
Fixtures can be registered in any file that ends with `_lamp.rb` anywhere in your `spec` or `test` directory. You'll also need to mount MagicLamp in your `config/routes.rb` like so:
```ruby
Rails.application.routes.draw do
  # ...
  mount MagicLamp::Genie, at: "/magic_lamp" if defined?(MagicLamp)
  # ...
end
```
### JavaScript side
You can use any rails JavaScript spec runner that runs your application's server. If you're using [Teaspoon](https://github.com/modeset/teaspoon), simply add `//= require magic_lamp` to your `spec_helper.js`.

## Usage
A fixture can be registered like so:
```ruby
MagicLamp.register_fixture do
  @order = Order.new
  render "orders/new"
end
```
Then in your JavaScript specs you can do this:
```js
MagicLamp.load('orders/new');
```
which will load the `"orders/new"` template into a `div` with an id of `magic-lamp`.

### `MagicLamp#register_fixture`

`MagicLamp#register_fixture` requires a block. In this block you are scoped to a controller instance, so you have access to private and public controller methods and that any instance variables set in this block will be available
to the rendered template.

Optionally, `register_fixture` accepts a controller class and the name of the fixture. By default the controller class is `ApplicationController` and the name is what is passed to `render` (either the string, symbol passed in, or the value of the `partial` or `template` key if it's a hash). Here's a more explicit version of the example above:
```ruby
MagicLamp.register_fixture(ApplicationController, "orders/new") do
  @orders = [Order.new, Order.new, Order.new]
  render "orders/new"
end
```
Specifying the controller class gives you access to private methods in the block and helper methods in the template as well as not having to provide the full path to the template or partial.
```ruby
MagicLamp.register_fixture(OrdersController) do
  @order = some_private_method(Order.new)
  render :index # index contains some special helper method
end
```
In this example, the template will be registered as `"orders/index"`. The default name for a fixture is the controller's name followed by the template (unless it's the `ApplicationController`). If you have name collisions (or if you just want a more informative fixture name), simply specify the name as the second
argument to `register_fixture`.
```ruby
MagicLamp.register_fixture(ApplicationController, "orders/new/with/errors") do
  @order = Order.new
  @errors = true
  render :new
end
```
Note: Only name your fixtures with characters that are the same in the url bar of a browser as they are everywhere else.

Also note: blocks using the default name will be executed twice (that's part of the magic required to get sweet defaults). If you don't want that to happen, just name your fixture.

### controller#render
Everything in the block you pass to `register_fixture` is scoped to an instance of the specified controller or the `ApplicationController`. `render` behaves normally for the most part. The only magic here is to set the `layout` option to default to `false`. Aside from that though, it's normal:
```ruby
MagicLamp.register_fixture(OrdersController) do
  render partial: "order",
    locals: { foo: "bar" },
    collection: [Order.new, Order.new, Order.new]
    # etc.
end
```
### MagicLamp JS
To load a fixture simply call `MagicLamp.load('fixture/name');`. To clear out the fixture `div`, call `MagicLamp.clean();`. If you call `MagicLamp.globalize();`, you be able to call `load` and `clean` right on `window`. If you'd like to preload all of your fixtures so you can stub network requests or something, just call `MagicLamp.preload();`.

The `id` of the `div` MagicLamp creates to hold the fixtures can be specified by setting `MagicLamp.id`.

### Errors
If there are any errors rendering your templates, MagicLamp will log them to the server log and throw an error in JavaScript. If the error in the JavaScript doesn't make the source of the problem clear, please check the server log. If that doesn't help, open up a `rails console` and enter `MagicLamp.load_lamp_files` and see if there are any errors. If not, try calling `MagicLamp.generate_all_fixtures` and seeing if the error shows up then.

### Sweet aliases
`MagicLamp#register_fixture` is aliased as `rub` and `wish`. On the JavaScript side of things, `load` is `rub` and `wish`. `preload` is `massage` and `wishForMoreWishes`. `clean` is `polish`.

## Contributing

1. Fork it
2. Clone it locally
3. `bundle install`
4. Run the `./bootstrap` script
5. Run the specs with `rake`
6. Create your feature branch (`git checkout -b my-new-feature`)
7. Commit your changes (`git commit -am 'Add some feature'`)
8. Push to the branch (`git push origin my-new-feature`)
9. Create new Pull Request

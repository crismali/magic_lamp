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
Fixtures can be registered in any file that ends with `_lamp.rb` anywhere in your `spec` or `test` directory.
### JavaScript side
You can use any rails JavaScript spec runner that runs your application's server. If you're using
(Teaspoon)[https://github.com/modeset/teaspoon], simply add `//= require magic_lamp` to your `spec_helper.js`.

## Usage
### Quick Example
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
which will load the "orders/new" template into a `div` with an id of `magic-lamp`.

The above example takes advantage of all of MagicLamp's default behaviors, so here's a breakdown of what's going on:

`MagicLamp#register_fixture` requires a block. In this block you are scoped to a controller instance, so you have
access to private and public controller methods and that any instance variables set in this block will be available
to the rendered template.

Optionally, `register_fixture` accepts a controller class and the name of the fixture. By default the controller class
is `ApplicationController` and the name is what is passed to `render` (either a string, symbol, or the value of the `partial`
or `template` key). Here's a more explicit version of the example above:
```ruby
MagicLamp.register_fixture(ApplicationController, "orders/new") do
  @order = Order.new
  render "orders/new"
end
```
The main advantages of specifying the controller class are access to private methods in the block and helper methods in
the template as well as not having to provide the full path to the template or partial.
```ruby
MagicLamp.register_fixture(OrdersController) do
  @order = some_private_method(Order.new)
  render :index # index contains some special helper method
end
```
In this example, the template will be registered as "orders/index"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

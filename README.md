MagicLamp
=========

MagicLamp makes sure that your JavaScript tests break when you change a template your code depends on.

Installation
------------

Add this line to your application's Gemfile:

    gem "magic_lamp"

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install magic_lamp

Setup
-----

### Rails side

Fixtures are defined in files with the extension: `_lamp.rb`. You can place them anywhere in your `spec` or `test` directory, but `spec/javascript/fixtures/` is a good place to put them. You'll also need to mount MagicLamp in your `config/routes.rb` like so:
```ruby
Rails.application.routes.draw do
  # ...
  mount MagicLamp::Genie, at: "/magic_lamp" if defined?(MagicLamp)
  # ...
end
```

### JavaScript side

You can use any rails JavaScript spec runner that runs your application's server. If you're using [Teaspoon](https://github.com/modeset/teaspoon), simply add `//= require magic_lamp` to your `spec_helper.js`.

### Example
Here's an [example app](https://github.com/crismali/magic_lamp/tree/master/example).

Usage
-----

A fixture can be registered like so: 
```ruby
MagicLamp.register_fixture(OrdersController) do
  @order = Order.new
  render :new
end
```

Then, to load this rendered template in your JavaScript specs, you do this:

```js
MagicLamp.load('orders/new');
```

This will load the `"orders/new"` template into a `div` with an id of `magic-lamp` in your spec environment.

### MagicLamp#register_fixture

`MagicLamp#register_fixture` requires a block. This block is scoped to the given controller instance, which provides access to private and public methods. Any instance variables defined in the block will also be available to the template.

If a controller is not passed to `register_fixture`, `ApplicationController` will be set as the scope for the block. Here's a more explicit version of the example above:

```ruby
MagicLamp.register_fixture(ApplicationController) do
  @orders = [Order.new, Order.new, Order.new]
  render "orders/new"
end
``` 
In this example, the template will be registered as `"orders/index"`. The default name for a fixture is the controller's name followed by the template (unless it's the `ApplicationController`). If you have name collisions (or if you just want a more informative fixture name), simply specify the name as the second argument to `register_fixture`.

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

To load all your fixtures in one ajax call (which is handy if you intend to stub network calls in subsequent tests), simply call:

```js
MagicLamp.preload();
```

To simply load one specific fixture call:

```js
MagicLamp.load('fixture/name');
```

To clear out the fixture element after a test run call:

```js
MagicLamp.clean();
```

If you wish to call the `MagicLamp` methods directly on the window call:

```js
MagicLamp.globalize();
```

This allows you to call `load` and `clean` directly on `window`

To specify the id `MagicLamp` uses for it's fixture element simply set `MagicLamp.id`:

```js
MagicLamp.id = "my-sweet-fixtures";
```

### Errors

If there are any errors rendering your templates, `MagicLamp` will log them to the server log and throw an error in JavaScript. If the error in the JavaScript doesn't make the source of the problem clear, please check the server log. If that doesn't help, open up a `rails console` and enter `MagicLamp.load_lamp_files` and see if there are any errors. If not, try calling `MagicLamp.generate_all_fixtures` and seeing if the error shows up then.

### Sweet aliases

#### Ruby

```ruby
MagicLamp.rub => register_fixture
MagicLamp.wish => register_fixture
```

### JavaScript
```js
MagicLamp.rub => load
MagicLamp.wish => load
MagicLamp.massage => preload
MagicLamp.wishForMoreWishes => preload
MagicLamp.polish => clean
```

## Contributing

1. Fork it
2. Clone it locally
3. Run the `./bootstrap` script
4. Run the specs with `rake`
5. Create your feature branch (`git checkout -b my-new-feature`)
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create new Pull Request

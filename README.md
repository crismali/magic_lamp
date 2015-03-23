Magic Lamp
=========
[![Gem Version](https://badge.fury.io/rb/magic_lamp.svg)](http://badge.fury.io/rb/magic_lamp)

Magic Lamp helps you get your Rails templates into your JavaScript tests. This means that way your JavaScript tests break
if you change your templates _and_ you don't have to create so many fixtures. Plus, it lets you test your views in JavaScript.
All you have to do is set up your data just like you would in a controller.

It's not required that you use [Teaspoon](https://github.com/modeset/teaspoon) as your JavaScript test runner, but you should.

Table of Contents
-----------------
1. [Installation](#installation)
2. [Basic Usage](#basic-usage)
3. [Where the files go](#where-the-files-go)
4. [Tasks](#tasks)
5. [Ruby API](#ruby-api)
6. [JavaScript API](#javascript-api)
7. [Errors](#errors)
8. [Sweet Aliases](#sweet-aliases)
9. [Contributing](#contributing)

Installation
------------

Add this line to your application's `Gemfile`:
```ruby
  gem "magic_lamp"
```
And then execute:

    $ bundle install

Or install it yourself with:

    $ gem install magic_lamp

Then paste `mount MagicLamp::Genie, at: "/magic_lamp" if defined?(MagicLamp)` into your `config/routes.rb`
like so:
```ruby
Rails.application.routes.draw do
  # ...
  mount MagicLamp::Genie, at: "/magic_lamp" if defined?(MagicLamp)
  # ...
end
```
This mounts the Magic Lamp engine in your app.

Then drop this:
```js
//= require magic_lamp
```
at the top of your `spec_helper.js` (assuming you're using [Teaspoon](https://github.com/modeset/teaspoon) or another JavaScript spec runner for Rails that allows the use of Sprockets directives).

(I highly recommend that you use [Teaspoon](https://github.com/modeset/teaspoon) as your JavaScript spec runner.)

Now you've got the basic setup.

In case you need it, [here's an example app](https://github.com/crismali/magic_lamp/tree/master/example).

### Debugging
Visit `/magic_lamp/lint` in your browser to lint your fixtures. You can also run `rake magic_lamp:lint` (or `rake mll` for short) to lint your fixtures from the command line.

### Loading Helpers

Simply `require` or `load` your helpers in the `magic_lamp_config.rb` file like so:

```ruby
# in magic_lamp_config.rb
Dir[Rails.root.join("spec", "support", "magic_lamp_helpers/**/*.rb")].each { |f| require f }
```

### With Database Cleaner

You don't need [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner) to use this gem, but this is probably the setup most people want.

First make sure you have Database Cleaner installed, then you'll want to do something like this:
```ruby
require "database_cleaner"

MagicLamp.configure do |config|

  DatabaseCleaner.strategy = :transaction

  config.before_each do
    DatabaseCleaner.start
  end

  config.after_each do
    DatabaseCleaner.clean
  end
end
```
in a file called `magic_lamp_config.rb` which you can place anywhere in your `spec` or `test` directories.

This way you can take advantage of `after_create` callbacks for your fixture setup without polluting
your database every time you run your JavaScript specs.

### With FactoryGirl

If you're using FactoryGirl, Magic Lamp will call `FactoryGirl.reload` for you to save you some autoloader pain.

Basic Usage
-----------
Magic Lamp will load all files in your `spec` or `test` directory that end with `_lamp.rb` (your app's
"lamp files). I'd recommend starting with a single `magic_lamp.rb` file and breaking it into smaller
files once it gets unwieldy (one for each controller would be a good approach).

In your lamp files you just call [`MagicLamp.fixture`](#fixture) like so:
```ruby
MagicLamp.fixture do
  @order = Order.new
  render partial: "orders/form"
end
```
Inside the block you pass to `fixture` you're in the scope of a controller so you
can set up any instance variables your templates depend on. In this case we're
using the default controller which is your `ApplicationController`. We're also
using the default name for the fixture which is whatever `render` receives to
identify the template (ie the symbol or string argument to `render` or
whatever is at the `:template` or `:partial` key in the argument hash).

`render` here also works normally except that it won't render the layout by default.

Then in your JavaScript you can call [`load`](#load):
```js
beforeEach(function() {
  MagicLamp.load("orders/form");
});
```
which will put the `orders/form` partial in a div with a class of `magic-lamp` (this all happens synchronously).
Then you can go nuts testing your JavaScript against your actual template. If you'd like to only make
one request for your templates, simply call [`MagicLamp.preload();`](#preload) in your `spec_helper.js` to
populate Magic Lamp's cache.

### Loading multiple templates

Just pass more fixture names to `MagicLamp.load` and it will load them all. For example:
```js
  beforeEach(function() {
    MagicLamp.load("orders/sidebar", "orders/form");
  });
```

with a sidebar template/partial that looks like this:
```html
  <div class="sidebar content">Links!</div>
```

and a form template/partial that looks like this:
```html
  <div class="form content">Inputs!</div>
```

will yield:
```html
  <div class="magic-lamp">
    <div class="sidebar content">Links!</div>
    <div class="form content">Inputs!</div>
  </div>
```

### Loading JSON fixtures and arbitrary strings
If you pass a block to `fixture` that does not invoke `render`, Magic Lamp will assume that you want the `to_json` representation of the return value of the block as your fixture (Magic Lamp will call this for you). If the return value is already a string, then Magic Lamp will return that string as is. In your JavaScript `MagicLamp.loadJSON` will return the `JSON.parse`d string while `MagicLamp.loadRaw` will return the string as is (you can also use `loadRaw` get the string version of a template rendered with `render` without Magic Lamp appending it to the DOM. `loadJSON` also won't interact with the DOM).

When sending down JSON or arbitrary strings, you must provide the fixture with a name since inferring one is impossible. 

It's also good to remember that in the fixture block that even though the controller isn't rendering anything for us, the block is still scoped to the given controller which gives us access to any controller methods we might want to use to massage our data structures.

For example: 

```ruby
MagicLamp.define(controller: OrdersController) do
  fixture(name: "some_json") do
    OrderSerializer.new(Order.new(price: 55))
  end

  fixture(name: "some_arbitrary_string") do
    some_method_on_the_controller_that_returns_a_string("Just some string")
  end
end
```

Then in your JavaScript:

```js
beforeEach(function() {
  var jsonObject = MagicLamp.loadJSON("orders/some_json");
  var someString = MagicLamp.loadRaw("orders/some_arbitrary_string");
});
```

### A few more examples
Here we're specifying which controller should render the template via the arguments hash
to `fixture`. This gives us access to helper methods in the `fixture` block
and in the template. It also means we don't need a fully qualified path to the rendered template
or partial.

Since we didn't specify the name of our fixture and we're not using the `ApplicationController`
to render the template the fixture will be named "orders/order".

We're also taking advantage of `render`'s `:collection` option.
```ruby
MagicLamp.fixture(controller: OrdersController) do
  orders = 3.times.map { Order.new }
  render partial: "order", collection: orders
end
```

Here we're specifying a name with the `:name` option that's passed to `fixture`.
This way we can load the fixture in our JavaScript with `MagicLamp.load("custom/name")` instead
of the default `MagicLamp.load("orders/foo")`. Custom names for fixtures must be url safe strings. We're also extending the controller and its view with the `AuthStub` module to stub some methods that we don't want executing in our fixtures.
```ruby
MagicLamp.fixture(name: "custom/name", extend: AuthStub) do
  render "orders/foo"
end
```

Here we're specifying both a controller and custom name. We're also setting the `params[:foo]`
mostly to demonstrate that we have access to all of the usual controller methods.
```ruby
MagicLamp.fixture(controller: OrdersController, name: "other_custom_name") do
  params[:foo] = "test"
  render :foo
end
```
If you're interested, [here's an example app](https://github.com/crismali/magic_lamp/tree/master/example).

### Drying up your fixtures
If you have several fixtures that depend on the same setup (same controller, extensions, etc), you can use the `define` method to dry things up:

```ruby
MagicLamp.define(controller: OrdersController, extend: AuthStub) do
  fixture do # orders/new
    @order = Order.new
    render :new
  end

  fixture(name: "customized_new") do # orders/customized_new
    session[:custom_user_info] = "likes movies"
    @order = Order.new
    render :new
  end

  fixture do # orders/form
    @order = Order.new
    render partial: "form"
  end

  define(namespace: "errors", extend: SomeErrorHelpers) do
    fixture(name: "form_without_price") do # orders/errors/form_without_price
      @order = Order.new
      @order.errors.add(:price, "can't be blank")
      render partial: "form"
    end

    fixture do # orders/errors/form
      @order = Order.new
      @order.errors.add(:address, "can't be blank")
      render partial: "form"
    end
  end
end
```

Where the files go
------------------------
### Config File
Magic Lamp first loads the `magic_lamp_config.rb` file. It can be anywhere in your `spec` or `test`
directory but it's not required.
### Lamp files
Magic Lamp will load any files in your `spec` or `test` directory that end with `_lamp.rb`.

Tasks
-----
### fixture_names
Call `rake magic_lamp:fixture_names` (or `rake mlfn`) to see a list of all of your app's fixture names.
### lint
Call `rake magic_lamp:lint` (or `rake mll`) to see if there are any errors when registering or rendering your fixtures.

Ruby API
--------
### fixture
(also aliased to `register_fixture` and `register`)

It requires a block that is invoked in the context of a controller. If render is called, it renders the specified template or partial the way the controller normally would. If `render` is not called in the block then MagicLamp will render the `to_json` representation of the return value of the block unless the return value is already a string. In that case, the string is rendered as is. 

It also takes an optional hash of arguments. The arguments hash recognizes:
* `:controller`
  * specifies any controller class that you'd like to have render the template or partial or have the block scoped to.
  * if specified it removes the need to pass fully qualified paths to templates to `render`
  * the controller's name becomes the default `namespace`, ie `OrdersController` provides a default namespace of `orders` resulting in a template named `orders/foo`
* `:name`
  * whatever you'd like name the fixture.
  * Specifying this option also prevents the block from being executed twice which could be a performance win. See [configure](#configure) for more.
  * this is required when you want to send down JSON or arbitrary strings.
* `:extend`
  * takes a module or an array of modules
  * extends the controller and view context (via Ruby's `extend`)
Also note that only symbol keys are recognized.

`fixture` will also execute any callbacks you've specified. See [configure](#configure) for more.

Example:
```ruby
MagicLamp.fixture(name: "foo", controller: OrdersController) do
  @order = Order.new
  render partial: "form"
end
```

### define
Allows you scope groups of fixtures with defaults and can be nested arbitrarily. It takes an optional hash and a required block. The hash accepts the following options:
* `:controller`
  * specifies any controller class that you'd like to have render the template or partial.
  * if specified it removes the need to pass fully qualified paths to templates to `render`
  * the controller's name becomes the default `namespace` if no namespace is provided, ie `OrdersController` provides a default namespace of `orders` resulting in a template named `orders/foo`
* `:name`
  * whatever you'd like name the fixture.
  * Specifying this option also prevents the block from being executed twice which could be a performance win. See [configure](#configure) for more.
* `:extend`
  * takes a module or an array of modules
  * extends the controller and view context (via Ruby's `extend`)
* `:namespace`
  * namespaces all fixtures defined within it
  * overrides the default controller namespace if passed
Also note that only symbol keys are recognized.

Inside of the block you can nest more calls to `define` and create fixtures
via the `fixture` method or one of its aliases.

Example:
```ruby
module DefinesFoo
  def foo
    "foo!"
  end
end

module AlsoDefinesFoo
  def foo
    "also foo!"
  end
end

MagicLamp.define(controller: OrdersController, extend: DefinesFoo) do

  fixture do # orders/edit
    foo #=> "foo!"
    @order = Order.create!
    render :edit
  end

  fixture do # orders/new
    foo #=> "foo!"
    @order = Order.new
    render :new
  end

  define(namespace: "errors", extend: AlsoDefinesFoo) do

    fixture do # orders/errors/edit
      foo #=> "also foo!"
      @order = Order.create!
      @order.errors.add(:price, "Can't be negative")
      render :edit
    end

    fixture(extend: DefinesFoo) do # orders/errors/new
      foo #=> "foo!"
      @order = Order.new
      @order.errors.add(:price, "Can't be negative")
      render :new
    end
  end
end
```

### configure
It requires a block to which it yields the configuration object. Here you can set:
* `before_each`
  * takes a block
  * defaults to `nil`
  * called before each block you pass to `fixture` is executed
  * note: if you call it a second time with a second block, only the second block will be executed
* `after_each`
  * takes a block
  * defaults to `nil`
  * called after each block you pass to `fixture` is executed
  * note: if you call it a second time with a second block, only the second block will be executed
* `global_defaults`
  * can be set to a hash of default options that every fixture generated will inherit from. Options passed to `define` and `fixture` take precedence.
  * accepts all of the keys `define` accepts
* `infer_names`
  * defaults to `true`
  * if set to true, Magic Lamp will try to infer the name of the fixture when not provided with a name parameter.
  * if set to false, the name parameter becomes required for `MagicLamp.fixture` (this can be done to improve performance or force your team to be more explicit)

Example:

```ruby
module AuthStub
  def current_user
    @current_user ||= User.create!(
      email: "foo@example.com",
      password: "password"
    )
  end
end

MagicLamp.configure do |config|

  # if you want to require the name parameter for the `fixture` method
  config.infer_names = false

  config.global_defaults = { extend: AuthStub }

  config.before_each do
    puts "I appear before the block passed to `fixture` executes!"
  end

  config.after_each do
    puts "I appear after the block passed to `fixture` executes!"
  end
end
```

JavaScript API
--------------
### clean
Calling `MagicLamp.clean()` will remove the Magic Lamp fixture container from the page.

If you don't want any dom elements from a fixture hanging around between specs, throw it
in a global `afterEach` block. Calling it with nothing to clean won't result in an error.

Example:
```js
  afterEach(function() {
    MagicLamp.clean();
  });
```
### load
Call `MagicLamp.load` to load a fixture. It requires the name of the fixture and which will be loaded into a `div` with a class of `magic-lamp`. It will destroy the previous fixture container if present so you never end up with duplicate fixture containers or end up with dom elements from previous loads. It will hit the network only on the first request for a given
fixture. If you never want `load` to hit the network, call [`MagicLamp.preload()`](#preload) before your specs.

You can load multiple fixtures into the dom at the same time by simply passing more arguments to `load`. 

The call to get your template is completely synchronous.

Example:
```js
  beforeEach(function() {
    MagicLamp.load("orders/foo");
  });

  // or if you wanted multiple fixtures...

  beforeEach(function() {
    MagicLamp.load("orders/foo", "orders/bar", "orders/foo", "orders/baz");
  });
```
### loadJSON
Returns the `JSON.parse`d version of the fixture. It's a convenience method for `JSON.parse(MagicLamp.loadRaw('some_json_fixture'));`. Look [here](#loading-json-fixtures-and-arbitrary-strings) for more.
### loadRaw
Returns the template, partial, JSON, or string as a raw string. Look [here](#loading-json-fixtures-and-arbitrary-strings) for more.
### preload
Call `MagicLamp.preload` to load all of your templates into MagicLamp's cache. This means you'll
only hit the network once, so the rest of your specs will be quicker and you can go wild stubbing the
network.

The call to get your templates is completely synchronous.

Example:
```js
// Probably should be in your `spec_helper.js`
MagicLamp.preload();
```
### fixtureNames
`MagicLamp.fixtureNames()` will return an array of all of the fixture names available in the cache
(which is all of them if you've called [`preload`](#preload)). It will also `console.log` them out.

Example
```js
MagicLamp.preload();
MagicLamp.fixtureNames(); // => ['orders/foo', 'orders/bar', 'orders/baz']
// logs 'orders/foo'
// logs 'orders/bar'
// logs 'orders/baz'
```

### globalize
`MagicLamp.globalize()` will put `MagicLamp.clean` and `MagicLamp.load` onto `window` for convenience.

Example:
```js
MagicLamp.globalize();

describe("Foo", function() {
  beforeEach(function() {
    load("orders/foo");
  });

  afterEach(function() {
    clean();
  });

  // ...
});
```
Errors
------
If there are errors rendering any of your templates, Magic Lamp will often throw a JavaScript
error. Errors will also appear in your server log (if you're running the in-browser specs).

To see errors outside of the server log (which may be noisy), you can run [`rake magic_lamp:lint`](#tasks) (or `rake mll`) or visit `/magic_lamp/lint` in your browser and display any errors in your fixtures.

If you get an `ActionView::MissingTemplate` error, try specifying the controller. This error is caused by a template that renders a partial
without using the fully qualified path to the partial. Specifying the controller should help Rails find the template.

Sweet aliases
-------------
### Ruby

```ruby
MagicLamp.register_fixture => fixture
MagicLamp.register => fixture
MagicLamp.rub => fixture
MagicLamp.wish => fixture
```

### JavaScript
```js
MagicLamp.rub => load
MagicLamp.wish => load
MagicLamp.massage => preload
MagicLamp.wishForMoreWishes => preload
MagicLamp.polish => clean
```

### Rake Tasks
```
rake mlfn => rake magic_lamp:fixture_names
rake mll => rake magic_lamp:lint
```

Contributing
------------
1. [Fork it](https://github.com/crismali/magic_lamp/fork)
2. Clone it locally
3. `cd` into the project root
4. Run the `./bootstrap` script
5. Run the specs with `appraisal rake`
6. Create your feature branch (`git checkout -b my-new-feature`)
7. Commit your changes (`git commit -am 'Add some feature'`)
8. Push to the branch (`git push origin my-new-feature`)
9. Create new Pull Request

Magic Lamp
=========
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

Basic Usage
-----------
Magic Lamp will load all files in your `spec` or `test` directory that end with `_lamp.rb` (your app's
"lamp files). I'd recommend starting with a single `magic_lamp.rb` file and breaking it into smaller
files once it gets unwieldy (one for each controller would be a good approach).

In your lamp files you just call [`MagicLamp.register_fixture`](#register_fixture) like so:
```ruby
MagicLamp.register_fixture do
  @order = Order.new
  render partial: "orders/form"
end
```
Inside the block you pass to `register_fixture` you're in the scope of a controller so you
can set up any instance variables your templates depend on. In this case we're using the
default controller which is your `ApplicationController`. We're also using the default
name for the fixture which is whatever `render` receives to identify the template (ie
the symbol or string argument to `render` or whatever is at the `:template` or `:partial`
key in the argument hash).

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

### A few more examples
Here we're specifying which controller should render the template via the arguments hash
to `register_fixture`. This gives us access to helper methods in the `register_fixture` block
and in the template. It also means we don't need a fully qualified path to the rendered template
or partial.

Since we didn't specify the name of our fixture and we're not using the `ApplicationController`
to render the template the fixture will be named "orders/order".

We're also taking advantage of `render`'s `:collection` option.
```ruby
MagicLamp.register_fixture(controller: OrdersController) do
  orders = 3.times.map { Order.new }
  render partial: "order", collection: orders
end
```

Here we're specifying a name with the `:name` option that's passed to `register_fixture`.
This way we can load the fixture in our JavaScript with `MagicLamp.load("custom/name")` instead
of the default `MagicLamp.load("orders/foo")`. Custom names for fixtures must be url safe strings.
```ruby
MagicLamp.register_fixture(name: "custom/name") do
  render "orders/foo"
end
```

Here we're specifying both a controller and custom name. We're also setting the `params[:foo]`
mostly to demonstrate that we have access to all of the usual controller methods.
```ruby
MagicLamp.register_fixture(controller: OrdersController, name: "other_custom_name") do
  params[:foo] = "test"
  render :foo
end
```
If you're interested, [here's an example app](https://github.com/crismali/magic_lamp/tree/master/example).
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
Call `rake magic_lamp:fixture_names` to see a list of all of your app's fixture names.
### lint
Call `rake magic_lamp:lint` to see if there are any errors when registering or rendering your fixtures.

Ruby API
--------
### register_fixture
(also aliased to `fixture` and `register`)

It requires a block that invokes `render` which is invoked in the context of a controller.
It also takes an optional hash of arguments. The arguments hash recognizes:
* `:controller`
  * specifies any controller class that you'd like to have render the template or partial.
  * if specified it removes the need to pass fully qualified paths to templates to `render`
  * the controller's name becomes the default `namespace`, ie `OrdersController` provides a default namespace of `orders` resulting in a template named `orders/foo`
* `:name`
  * whatever you'd like name the fixture.
  * Specifying this option also prevents the block from being executed twice which could be a performance win. See [configure](#configure) for more.
* `:extend`
  * takes a module or an array of modules
  * extends the controller and view context (via Ruby's `extend`)
Also note that only symbol keys are recognized.

`register_fixture` will also execute any callbacks you've specified. See [configure](#configure) for more.

Example:
```ruby
MagicLamp.register_fixture(name: "foo", controller: OrdersController) do
  @order = Order.new
  render partial: :form
end
```

### define
Allows you scope groups of fixtures with defaults and can be nested arbitrarily. It takes an optional hash and a required block. The hash accepts the following options:
* `:controller`
  * specifies any controller class that you'd like to have render the template or partial.
  * if specified it removes the need to pass fully qualified paths to templates to `render`
  * the controller's name becomes the default `namespace`, ie `OrdersController` provides a default namespace of `orders` resulting in a template named `orders/foo`
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

Example:
```ruby
module DefinesFoo
  def foo
    "foo!"
  end
end

module AlsoDefinesFoo
  def foo
    "also Foo!"
  end
end

MagicLamp.define(controller: OrdersController, extend: DefinesFoo) do |genie|

  genie.fixture do # orders/edit
    foo #=> "foo!"
    @order = Order.create!
    render :edit
  end

  genie.fixture do # orders/new
    foo #=> "foo!"
    @order = Order.new
    render :new
  end

  genie.define(namespace: "errors", extend: AlsoDefinesFoo) do |errors_genie|
    errors_genie.fixture do # orders/errors/edit
      foo #=> "also foo!"
      @order = Order.create!
      @order.errors.add(:price, "Can't be negative")
      render :edit
    end

    errors_genie.fixture(extend: DefinesFoo) do # orders/errors/new
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
  * called before each block you pass to `register_fixture` is executed
  * note: if you call it a second time with a second block, only the second block will be executed
* `after_each`
  * takes a block
  * defaults to `nil`
  * called after each block you pass to `register_fixture` is executed
  * note: if you call it a second time with a second block, only the second block will be executed
* `infer_names`
  * defaults to `true`
  * if set to true, Magic Lamp will try to infer the name of the fixture when not provided with a name parameter.
  * if set to false, the name parameter becomes required for `MagicLamp.register_fixture` (this can be done to improve performance or force your team to be more explicit)

Example:

```ruby
MagicLamp.configure do |config|

  # if you want to require the name parameter for `MagicLamp.register_fixture`
  config.infer_names = false

  config.before_each do
    puts "I appear before the block passed to register fixture executes!"
  end

  config.after_each do
    puts "I appear after the block passed to register fixture executes!"
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
Call `MagicLamp.load` to load a fixture. It requires the name of the fixture and the fixture
will be loaded into a `div` with a class of `magic-lamp`. It will destroy the previous fixture
container if present so you never end up with duplicate fixture containers or end up with
dom elements from previous loads. It will hit the network only on the first request for a given
fixture. If you never want `load` to hit the network, call `MagicLamp.preload()` before your specs.

The call to get your template is completely synchronous.

Example:
```js
  beforeEach(function() {
    MagicLamp.load("orders/foo");
  });
```
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

To see errors outside of the server log (which may be noisy), you can run [`rake magic_lamp:lint`](#tasks)
which will attempt to render all of your templates. If there are any errors they'll show up there in a
somewhat less noisy environment.

If you get an `ActionView::MissingTemplate` error, try specifying the controller. This error is caused by a template that renders a partial
without using the fully qualified path to the partial. Specifying the controller should help Rails find the template.

Sweet aliases
-------------
### Ruby

```ruby
MagicLamp.fixture => register_fixture
MagicLamp.register => register_fixture
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

Contributing
------------
1. Fork it
2. Clone it locally
3. Run the `./bootstrap` script
4. Run the specs with `rake`
5. Create your feature branch (`git checkout -b my-new-feature`)
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create new Pull Request

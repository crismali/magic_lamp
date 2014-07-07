# MagicLamp

MagicLamp ensures that if you change some markup in your templates that your JavaScript depends on that
your tests will break. This is accomplished by generating fixture files from your actual templates just before running your JavaScript specs.

## Installation

Add this line to your application's Gemfile:

    gem "magic_lamp"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install magic_lamp
## Usage
### Basic usage
In any file that ends in `_lamp.rb` in your `spec` or `test` directory:
```ruby
MagicLamp.create_fixture("fixture_name", SomeController) do

  @instance_variable_your_template_depends_on = true
  # instance variables set in this block will be available to
  # the template you render. You also have access to the usual
  # controller methods and helpers here
  params[:foo] = "some param that's rendered for some reason"

  render :template_to_be_rendered
  # or
  # render partial: :partial_to_be_rendered
  # or
  # render partial: :foo, collection: [Foo.new, Foo.new, Foo.new]
  # or
  # pretty much anything you can normall do with render
end
```
Then if you ran:

    $ rake magic_lamp
There would be a file called `fixture_name.html` containing the rendered template in `tmp/magic_lamp`.
A more in depth example can be found below.

### Rake tasks
The basic tasks are:
* `rake magic_lamp:create_fixtures` - generates fixtures from `_lamp` files
* `rake magic_lamp:clean` - deletes fixtures (by removing `tmp/magic_lamp`)
* `rake magic_lamp` - alias for `rake magic_lamp:create_fixtures`

Since you'll probably always want to run the create fixtures task before you run your JavaScript specs, MagicLamp comes with some convenience tasks that create your fixtures and then immediately run your JavaScript specs:
* `rake magic_lamp:evergreen` - [Evergreen](https://github.com/abepetrillo/evergreen) integration (you'll need `gem "evergreen", require: "evergreen/rails"` for this to work)
* `rake magic_lamp:jasmine` - [Jasmine Gem](https://github.com/pivotal/jasmine-gem) integration
* `rake magic_lamp:jasmine_rails` - [JasmineRails](https://github.com/searls/jasmine-rails) integration
* `rake magic_lamp:konacha` - [Konacha](https://github.com/jfirebaugh/konacha) integration
* `rake magic_lamp:teaspoon` - [Teaspoon](https://github.com/modeset/teaspoon) integration

### In depth example
Let"s assume we have `Order` model and `OrdersController` and that we want to test our JavaScript against the `views/orders/index.html.erb` that looks like this:
```html
<ul class="orders">
<% @orders.each do |order| %>
  <li>
    <%= order_name(order) %>
  </li>
<% end %>
</ul>
```
The only dependencies in this template are `@orders` and the `order_name` helper method. So anywhere in `spec` or `test` we make a file that ends in `_lamp.rb` and write:

```ruby
MagicLamp.create_fixture("orders_index", OrdersController) do
  @orders = [
    Order.new(name: "foo", id: 1),
    Order.new(name: "bar", id: 2),
    Order.new(name: "baz", id: 3)
  ]
  render :index
end
```
We want our fixture file to be named `orders_index.html`, so we pass in `"orders_index"` as the first argument. We pass in `OrdersController as the second argument because it's the only controller that knows about the `order_name` helper.

So after we run `rake magic_lamp` we end up with a `orders_index.html` file in `tmp/magic_lamp` that looks like this:
```html
<ul class="orders">
  <li>
    foo: 1
  </li>
  <li>
    bar: 2
  </li>
  <li>
    baz: 3
  </li>
</ul>
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

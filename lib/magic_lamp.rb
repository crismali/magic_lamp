require "rake"

require "magic_lamp/engine"
require "magic_lamp/constants"
require "magic_lamp/callbacks"

require "magic_lamp/configuration"
require "magic_lamp/defaults_manager"
require "magic_lamp/fixture_creator"
require "magic_lamp/render_catcher"

require "tasks/lint_task"
require "tasks/fixture_names_task"

module MagicLamp
  class << self
    attr_accessor :registered_fixtures, :configuration

    def path
      Rails.root.join(directory_path)
    end

    def register_fixture(options = {}, &render_block)
      raise_missing_block_error(render_block, __method__)

      options[:controller] ||= ::ApplicationController
      options[:namespace] ||= options[:controller].controller_name
      options[:extend] = Array(options[:extend])
      options[:render_block] = render_block
      fixture_name = namespaced_fixture_name_or_raise(options)

      if registered?(fixture_name)
        raise AlreadyRegisteredFixtureError, "a fixture called '#{fixture_name}' has already been registered"
      end

      registered_fixtures[fixture_name] = options
    end

    REGISTER_FIXTURE_ALIASES.each do |method_name|
      alias_method method_name, :register_fixture
    end

    def configure(&block)
      raise_missing_block_error(block, __method__)
      self.configuration = Configuration.new
      block.call(configuration)
    end

    def define(options = {}, &block)
      raise_missing_block_error(block, __method__)
      defaults_manager = DefaultsManager.new(configuration, options)
      defaults_manager.instance_eval(&block)
      defaults_manager
    end

    def registered?(fixture_name)
      registered_fixtures.key?(fixture_name)
    end

    def load_config
      load_all(config_files)
    end

    def load_lamp_files
      self.registered_fixtures = {}
      load_config
      load_all(lamp_files)
    end

    def generate_fixture(fixture_name)
      unless registered?(fixture_name)
        raise UnregisteredFixtureError, "'#{fixture_name}' is not a registered fixture"
      end
      controller_class, block, extensions = registered_fixtures[fixture_name].values_at(:controller, :render_block, :extend)
      FixtureCreator.new(configuration).generate_template(controller_class, extensions, &block)
    end

    def generate_all_fixtures
      load_lamp_files
      registered_fixtures.keys.each_with_object({}) do |fixture_name, fixtures|
        fixtures[fixture_name] = generate_fixture(fixture_name)
      end
    end

    private

    def namespaced_fixture_name_or_raise(options)
      fixture_name = options.delete(:name)
      controller_class, render_block = options.values_at(:controller, :render_block)
      fixture_name = fixture_name_or_raise(fixture_name, controller_class, render_block)
      namespace_fixture_name(fixture_name, options[:namespace])
    end

    def namespace_fixture_name(fixture_name, namespace)
      namespace_without_application = strip_application(namespace)
      full_name = compose_full_name(namespace_without_application, fixture_name)

      full_name.split(FORWARD_SLASH).each do |namespace_piece|
        namespace_piece_doubled = [namespace_piece, namespace_piece].join(FORWARD_SLASH)
        full_name.gsub!(namespace_piece_doubled, namespace_piece)
      end
      full_name
    end

    def strip_application(namespace)
      namespace.gsub(APPLICATION_MATCHER, EMPTY_STRING)
    end

    def compose_full_name(namespace, fixture_name)
      [namespace, fixture_name].select(&:present?).join(FORWARD_SLASH)
    end

    def fixture_name_or_raise(fixture_name, controller_class, block)
      if fixture_name.nil? && configuration.infer_names
        default_fixture_name(controller_class, block)
      elsif fixture_name.nil?
        raise ArgumentError, "You must specify a name since `infer_names` is configured to `false`"
      else
        fixture_name
      end
    end

    def raise_missing_block_error(block, method_name)
      if block.nil?
        raise ArgumentError, "MagicLamp##{method_name} requires a block"
      end
    end

    def config_files
      Dir[path.join(STARS, "magic#{LAMP}_config.rb")]
    end

    def lamp_files
      Dir[path.join(STARS, "*#{LAMP}.rb")]
    end

    def default_fixture_name(controller_class, block)
      first_arg = first_render_arg(block)
      fixture_name = template_name(first_arg).to_s
      if fixture_name.blank?
        raise AmbiguousFixtureNameError, "Unable to infer fixture name"
      end
      fixture_name
    end

    def first_render_arg(block)
      render_catcher = RenderCatcher.new(configuration)
      render_catcher.first_render_argument(&block)
    end

    def template_name(render_arg)
      if render_arg.is_a?(Hash)
        render_arg[:template] || render_arg[:partial]
      else
        render_arg
      end
    end

    def directory_path
      Dir.exist?(Rails.root.join(SPEC)) ? SPEC : TEST
    end

    def load_all(files)
      files.each { |file| load file }
    end
  end
end

MagicLamp.configuration = MagicLamp::Configuration.new

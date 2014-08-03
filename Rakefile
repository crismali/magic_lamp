begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

require "rspec/core/rake_task"
desc "run rspec specs"
RSpec::Core::RakeTask.new(:spec) do |t|
end

namespace :spec do
  desc "runs integration tests only"
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = "spec/integration/**/*_spec.rb"
    t.rspec_opts = "--tag integration"
  end

  desc "Run both test suites"
  task :all do
    Rake::Task["spec"].invoke
    system "bundle exec teaspoon"
  end
end

task default: ["spec:all"]

Bundler::GemHelper.install_tasks

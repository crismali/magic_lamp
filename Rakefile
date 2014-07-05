begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

require "rspec/core/rake_task"

namespace :spec do
  desc "runs integration tests only"
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = "spec/integration/**/*_spec.rb"
    t.rspec_opts = "--tag integration"
  end

  desc "Run both test suites"
  task :all do
    system "bundle exec rspec"
    Rake::Task["spec:integration"].invoke
  end
end

task default: ["spec:all"]

Bundler::GemHelper.install_tasks

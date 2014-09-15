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

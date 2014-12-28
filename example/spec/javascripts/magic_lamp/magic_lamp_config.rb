require "database_cleaner"

module AuthenticationStub
  def current_user
    @current_user ||= User.create! email: "bar#{SecureRandom.hex(3)}@example.com", password: "password"
  end
end

MagicLamp.configure do |config|
  DatabaseCleaner.strategy = :transaction

  config.before_each do
    DatabaseCleaner.start
  end

  config.after_each do
    DatabaseCleaner.clean
  end
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end

RspecApiDocumentation.configure do |config|
  config.format = :json
end

RSpec.configure do |config|
  
  #config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end 

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end 

  config.before(:each) do
    DatabaseCleaner.start
  end 

  config.after(:each) do
    DatabaseCleaner.clean
  end 

  config.include Requests::JsonHelpers
  config.include Requests::LoginHelpers
end

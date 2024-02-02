ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'json'
require_relative '../config/environment'
require_relative '../app/models/user'
require_relative '../app/controllers/users_controller'
require 'factory_bot'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

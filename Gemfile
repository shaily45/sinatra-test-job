# Gemfile
source 'http://rubygems.org'
ruby '3.1.0'
# rack-contrib gives us access to Rack::JSONBodyParser allowing Sinatra (which is built on Rack) to parse requests whose body is in JSON format
gem 'rack-contrib', '~> 2.3', require: 'rack/contrib'
# sinatra-cross_origin allows our Sinatra API to respond to cross-origin requests
gem 'sinatra-cross_origin', '~>0.4.0'

# these should be familiar from before. Allow us to set up our pg database with activerecord and sinatra.
gem 'activerecord', '~> 7.1.0'
gem 'dotenv', '~> 2.8.1'
gem 'pg', '~> 1.5', '>= 1.5.4'
gem 'require_all', '~> 3.0.0'
gem 'sinatra-activerecord', '~> 2.0.27'

# puma is a basic web server that we can run so our application can respond to requests in production
gem 'byebug', '~> 11.1.3'
gem 'puma', '~> 6.4.2'
# you know about pry at this point, used to allow us to stop our code while it's running for debugging purposes.
gem 'pry', '~> 0.14.2'
# bcrypt is a gem used to encrypt user passwords so that they are not stored in plain text within the database.
gem 'bcrypt', '~> 3.1.20'
# tux adds a command called `tux` that has access to all of our classes (similar to what we did with rake console manually)
gem 'tux', '~> 0.3.0'

gem 'carrierwave', '~> 3.0'
gem 'i18n', '~> 1.14.1'
gem 'jwt', '~> 2.7.1'
gem 'pony', '~> 1.13.1'
gem 'rake', '~> 13.1.0'
gem 'rotp', '~> 6.2.1'
gem 'rqrcode', '~> 2.2.0'

# these gems are specialized for testing our application.
group :test do
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git' # for resetting the test database before and after the test suite runs
  gem 'factory_bot', '~> 6.4.5'
  gem 'faker', '~>3.2.3'
  gem 'rack-test', '~> 2.1.0'
  gem 'rspec', '~> 3.12.0'
  gem 'simplecov', '~> 0.22.0'
end

gem "rackup", "~> 2.1"

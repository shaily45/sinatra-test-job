# config/enviroment.rb

ENV['SINATRA_ENV'] ||= 'development'
require 'i18n'
require 'sinatra/base'
require 'bundler/setup'
require 'require_all'
require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'
require 'securerandom'
require 'rqrcode'
require 'base64'
require 'chunky_png'
require 'rotp'
require 'pony'
require 'jwt'
require_all 'app/**/*.rb'
require 'dotenv/load'
require 'puma'
set :port, 4567

before do
  I18n.locale = I18n.default_locale
end

configure do
  enable :sessions
  set :database, {
    adapter: 'postgresql',
    database: ENV['DB_NAME'],
    username: ENV['DB_USERNAME'],
    password: ENV['DB_PASSWORD'],
    host: ENV['DB_HOST'],
    port: ENV['DB_PORT'] || 5432
  }

  # SMTP Configuration for Pony
  Pony.options = {
    via: 'smtp',
    via_options: {
      address: ENV['SMTP_ADDRESS'],
      port: ENV['SMTP_PORT'],
      user_name: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD'],
      authentication: :plain,
      domain: ENV['SMTP_DOMAIN'] || 'localhost.localdomain'
    }
  }

  CarrierWave.configure do |config|
    config.root = File.dirname(__FILE__) + '/public'
  end

  # i18 for the localization
  I18n.load_path << File.join(settings.root, 'locales/en.yml')
  I18n.default_locale = :en

  use UsersController
end

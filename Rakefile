# frozen_string_literal: true

ENV['SINATRA_ENV'] ||= 'development'

require_relative './config/environment'
require 'sinatra/activerecord/rake'
require 'pry'

desc 'Start our app console'
task :console do
  ActiveRecord::Base.logger = Logger.new($stdout)
  Pry.start
end

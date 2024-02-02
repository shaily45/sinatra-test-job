# frozen_string_literal: true

require './config/environment'

use Rack::JSONBodyParser
run ApplicationController

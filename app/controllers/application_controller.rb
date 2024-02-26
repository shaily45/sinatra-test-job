# frozen_string_literal: true

class ApplicationController < Sinatra::Base
  require_all 'app/**/*.rb'

  include ApplicationMethods

  private

  def authenticate_request
    token = request.env['HTTP_TOKEN']
    auth = AuthorizeApiRequest.call(token, request)
    @current_user = auth.result
    halt 401, render_unauthorized_response(auth.errors) unless @current_user.present? && @current_user.is_a?(User)
  end  
end

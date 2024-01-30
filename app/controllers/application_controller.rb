class ApplicationController < Sinatra::Base
  require_all 'app/**/*.rb'

  include ApplicationMethods

  private

  def authenticate_request
    auth = AuthorizeApiRequest.call(request.env['HTTP_TOKEN'])
    @current_user = auth.result
    render_unauthorized_response(auth.errors) and return unless @current_user.present?
  end
end

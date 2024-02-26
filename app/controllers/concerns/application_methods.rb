# frozen_string_literal: true

module ApplicationMethods
  extend ActiveSupport::Concern

  included do
    before ['/signup', '/login', '/verify_two_factor_authentication',
            '/change_password'] do
      parse_request
    end

    before ['/disable_two_factor_authentication', '/change_password', '/enable_two_factor_authentication', '/uploads/*', '/verify_two_factor_authentication'] do
      authenticate_request
    end
  end

  private

  def handle_exceptions
    yield
  rescue StandardError => e
    handle_error(e)
  end

  def handle_error(e)
    status_code = case e
                  when ActiveRecord::RecordInvalid
                    400
                  when ActiveRecord::RecordNotFound
                    404
                  when ArgumentError
                    400
                  when StandardError
                    500
                  end

    status status_code
    content_type :json
    { success: false, message: e.message }.to_json
  end

  def render_unprocessable_entity(message)
    json_response({
                    success: false,
                    errors: [message]
                  }, 422)
  end

  def render_unauthorized_response(message)
    json_response({
                    success: false,
                    errors: [message]
                  }, 401) and return true
  end

  def render_success_response(resources = {}, message = '', status = 200, meta = {})
    json_response({
                    success: true,
                    message:,
                    data: resources,
                    meta:
                  }, status)
  end

  def json_response(options = {}, status = 500)
    { response: JsonResponse.new(options), status: }.to_json
  end

  def render_unauthorized_response(message = {})
    json_response({
                    success: false,
                    message: ,
                    errors: [message]
                  }, 401)
  end

  def array_serializer
    ActiveModel::Serializer::CollectionSerializer
  end

  def single_serializer
    ActiveModelSerializers::SerializableResource
  end
end

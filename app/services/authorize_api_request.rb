# frozen_string_literal: true

class AuthorizeApiRequest < ApplicationService
  attr_reader :token, :errors, :request

  def initialize(token = nil, request = nil)
    @token = token
    @request = request
    @errors = ActiveModel::Errors.new(self)
  end

  def call
    user
  end

  def user
    decoded_auth_token
    if @decoded_auth_token
      @user ||= User.find(decoded_auth_token.first['user_id'])
      return @user if upload_request?
      if validate_request_token_type
        return errors.add(:token, I18n.t('errors.invalid_token'))        
      end
    end
    @user
  end

  def decoded_auth_token
    @decoded_auth_token ||= JWT.decode(token, ENV['SECRET_KEY_BASE'], true)
  rescue JWT::DecodeError
    errors.add(:token, I18n.t('errors.invalid_token'))
  end

  def upload_request?
    @user&.update(two_factor_enabled: true) if request.env['REQUEST_PATH'].include?('uploads')
  end

  def handle_two_factor_authentication
    errors.add(:token, I18n.t('errors.invalid_token'))
  end

  def http_auth_header
    headers['Authorization']&.split(' ')&.last
  end

  def validate_request_token_type
    @user.two_factor_enabled? && decoded_auth_token.first['token_type'] == 'login' && !request.env['REQUEST_PATH'].include?('verify_two_factor_authentication')
  end
end

class AuthorizeApiRequest < ApplicationService
  attr_reader :token

  def initialize(token = nil)
    @token = token
  end

  def call
    user
  end

  def user
    @user ||= User.find(decoded_auth_token.first['user_id']) if decoded_auth_token
    @user || { errors: { token: 'invalid token' } } && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JWT.decode(token, 'your_secret_key')
  end

  def http_auth_header
    return headers['Authorization'].split(' ').last if headers['Authorization'].present?

    nil
  end
end

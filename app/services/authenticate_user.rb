# frozen_string_literal: true

require 'jwt'
class AuthenticateUser < ApplicationService
  def initialize(email, password, remember_me = false)
    @email = email
    @password = password
    @remember_me = remember_me
    @errors = ActiveModel::Errors.new(self)
  end

  attr_accessor :email, :password, :remember_me, :errors

  def call
    user = authenticate_user

    return handle_authentication_error('user_not_found') if user.nil?
    return handle_authentication_error('invalid_credentials') unless user.is_a?(User)

    if user.two_factor_enabled?
      totp = generate_otp(user)
      generate_success_response(user)
    else
      user.update(last_login: Time.now)
      { status: 'success', token: encode_token(user, calculate_expiry, 'login'),
        user: allowed_attributes(user) }
    end    
  end

  private

  def calculate_expiry
    remember_me ? 30.days.from_now.to_i : 24.hours.from_now.to_i
  end

  def encode_token(user, expiry, token_type)
    JWT.encode({ user_id: user.id, exp: expiry, user_type: 'User', token_type: token_type}, ENV['SECRET_KEY_BASE'])
  end

  def authenticate_user
    user = User.find_by(email:)
    return nil unless user.present?
    return :invalid_credentials unless user&.authenticate(password)

    user
  end

  def allowed_attributes(user)
    { email: user.email, two_factor_enabled: user.two_factor_enabled, created_at: user.created_at,
      updated_at: user.updated_at }
  end

  def generate_otp(user)
    ROTP::TOTP.new(user&.otp_secret, issuer: 'My Service')
  end

  def handle_authentication_error(error_key)
    { status: 'error', message: I18n.t("errors.#{error_key}") }
  end

  def generate_success_response(user)
    { 
      status: 'success', 
      otp: true, 
      token: encode_token(user, calculate_expiry, 'login'),
      two_factor_enabled: user.two_factor_enabled
    }
  end  
end

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
    expiry = remember_me ? 30.days.from_now.to_i : 24.hours.from_now.to_i
    user ||= authenticate_user
    if user.two_factor_enabled?
      totp = generate_otp(user)
      { status: 'success', otp: true } if totp.present?
    elsif user.instance_of?(User)
      user.update(last_login: Time.now)
      { status: 'success', token: JWT.encode({ user_id: user.id, exp: expiry, user_type: 'User' }, ENV['SECRET_KEY_BASE']),
        user: allowed_attributes(user) }
    else
      { status: 'error', errors: }
    end
  end

  def authenticate_user
    user = User.find_by(email:)
    return errors.add(:user_authentication, I18n.t('errors.user_not_found')) unless user.present?
    return user if user&.authenticate(password)

    errors.add(:user_authentication, I18n.t('errors.invalid_credentials'))
  end

  def allowed_attributes(user)
    { email: user.email, two_factor_enabled: user.two_factor_enabled, created_at: user.created_at,
      updated_at: user.updated_at }
  end

  def generate_otp(user)
    ROTP::TOTP.new(user&.otp_secret, issuer: 'My Service')
  end
end

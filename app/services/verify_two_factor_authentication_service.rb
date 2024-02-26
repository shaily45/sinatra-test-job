# frozen_string_literal: true

class VerifyTwoFactorAuthenticationService
  attr_accessor :user, :request, :parsed_params, :errors

  def initialize(user, request, parsed_params)
    @user = user
    @request = request
    @parsed_params = parsed_params
    @errors = ActiveModel::Errors.new(self)
  end

  def verify_authentication
    totp = get_otp(user)

    if totp.now == @parsed_params['otp']
      generate_success_response(user)
    else
      handle_invalid_otp_error
    end
  rescue StandardError => e
    handle_unexpected_error(e)
  end

  private

  def get_otp(user)
    ROTP::TOTP.new(user.otp_secret)
  end

  def generate_success_response(user)
    { 
      status: 'success', 
      message: I18n.t('two_factor_authentication.otp_verified'),
      token: encode_user_token(user) 
    }
  end

  def encode_user_token(user)
    JWT.encode({ user_id: user.id, exp: (Time.now + 24.hours).to_i, user_type: 'User', token_type: '2fa'}, ENV['SECRET_KEY_BASE'])
  end

  def handle_user_not_found_error
    errors.add(:user_authentication, I18n.t('errors.user_not_found'))
  end

  def handle_invalid_otp_error
    errors.add(:user_authentication, I18n.t('two_factor_authentication.invalid_otp'))
  end

  def handle_unexpected_error(exception)
    errors.add(:user_authentication, "Unexpected error: #{exception.message}")
  end
end

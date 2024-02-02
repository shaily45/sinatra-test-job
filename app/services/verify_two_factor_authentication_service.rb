# frozen_string_literal: true

class VerifyTwoFactorAuthenticationService
  attr_accessor :request, :parsed_params, :errors

  def initialize(request, parsed_params)
    @request = request
    @parsed_params = parsed_params
    @errors = ActiveModel::Errors.new(self)
  end

  def verify_authentication
    user = find_user_by_token
    return errors.add(:user_authentication, I18n.t('errors.user_not_found')) if user.nil?

    totp = get_otp
    if totp.now == @parsed_params['otp']
      generate_success_response(user)
    else
      errors.add(:user_authentication, I18n.t('two_factor_authentication.invalid_otp'))
    end
  rescue StandardError
    errors.add(:user_authentication, 'Unexpected error')
  end

  private

  def find_user_by_token
    user_id = AuthorizeApiRequest.new(@request.env['HTTP_TOKEN']).decoded_auth_token.first['user_id']
    User.find(user_id)
  end

  def get_otp
    ROTP::TOTP.new(find_user_by_token.otp_secret)
  end

  def generate_success_response(user)
    { status: 'success', message: I18n.t('two_factor_authentication.otp_verified'),
      token: JWT.encode(user, (Time.now + 24.hours).to_i) }.to_json
  end
end

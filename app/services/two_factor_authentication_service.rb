# frozen_string_literal: true

class TwoFactorAuthenticationService
  attr_accessor :user, :request, :errors

  def initialize(user, request)
    @user = user
    @request = request
    @errors = ActiveModel::Errors.new(self)
  end

  def enable_2fa_authentication
    return handle_already_enabled_error if user.two_factor_enabled?

    { status: 'success', data: allowed_attributes(user) } if update_user
  rescue StandardError => e
    handle_unexpected_error(e)
  end

  private

  def update_user
    user.update(
      otp_secret: ROTP::Base32.random_base32,
    )
  end

  def generate_qr_code_url
    qr_code_content = "otpauth://totp/#{user.email}?secret=#{user.otp_secret}&issuer=YourApp"
    get_qr_code(qr_code_content)
    convert_qr_to_image
    "#{request.base_url}#{user.qr_code.url}"
  end

  def get_qr_code(qr_code_content)
    @qr_code = RQRCode::QRCode.new(qr_code_content)
  end

  def convert_qr_to_image
    qr_image = @qr_code.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 500
    )
    user.qr_code = File.open(qr_image.save('qr_code.png'))
    user.save
  end

  def allowed_attributes(user)
    { email: user.email, qr_code_url: generate_qr_code_url, created_at: user.created_at, updated_at: user.updated_at }
  end

  def handle_user_not_found_error
    errors.add(:user_authentication, I18n.t('errors.user_not_found'))
  end

  def handle_already_enabled_error
    errors.add(:user_authentication, I18n.t('two_factor_authentication.already_enabled'))
  end

  def handle_unexpected_error(exception)
    errors.add(:user_authentication, "Unexpected error: #{exception.message}")
  end
end

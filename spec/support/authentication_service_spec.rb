require 'jwt'
require 'rotp'
require 'spec_helper'

RSpec.describe AuthenticateUser do
  let(:valid_email) { 'user@example.com' }
  let(:valid_password) { 'ValidPassword1#' }
  let(:valid_user) { FactoryBot.create(:user, two_factor_enabled: false) }

  describe '#call' do
    context 'when authentication is successful without two-factor' do
      it 'returns success response with token and user details' do
        allow(User).to receive(:find_by).with(email: valid_email).and_return(valid_user)
        allow(valid_user).to receive(:authenticate).with(valid_password).and_return(true)

        expect(ROTP::TOTP).not_to receive(:new)

        authenticate_user = described_class.new(valid_email, valid_password, false).call
        expect(authenticate_user).to include(
          status: 'success',
          token: anything,
          user: hash_including(email: valid_user.email, two_factor_enabled: false)
        )
      end
    end

    context 'when authentication is successful with two-factor' do
      it 'returns success response with OTP information' do
        allow(User).to receive(:find_by).with(email: valid_email).and_return(valid_user)
        allow(valid_user).to receive(:authenticate).with(valid_password).and_return(true)

        totp_double = instance_double(ROTP::TOTP, present?: true)
        allow(ROTP::TOTP).to receive(:new).with(valid_user.otp_secret, issuer: 'My Service').and_return(totp_double)
        valid_user.update(two_factor_enabled: true)
        authenticate_user = described_class.new(valid_email, valid_password, false).call

        expect(authenticate_user).to include(
          status: 'success',
          otp: true
        )
      end
    end

    context 'when user is not found' do
      it 'returns error response' do
        allow(User).to receive(:find_by).with(email: valid_email).and_return(nil)

        authenticate_user = described_class.new(valid_email, valid_password, false).call

        expect(authenticate_user).to include(
          status: 'error',
          message: 'User not found'
        )
      end
    end

    context 'when authentication fails' do
      it 'returns error response' do
        allow(User).to receive(:find_by).with(email: valid_email).and_return(valid_user)
        allow(valid_user).to receive(:authenticate).with(valid_password).and_return(false)

        authenticate_user = described_class.new(valid_email, valid_password, false).call

        expect(authenticate_user).to include(
          status: 'error',
          message: 'Invalid Credentials'
        )
      end
    end
  end
end
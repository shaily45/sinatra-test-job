require 'spec_helper'
require 'factory_bot'
require 'faker'
require 'simplecov'
require 'api_helper'
require 'rack/test'
require 'jwt'
require 'rotp'
require 'bcrypt'
require 'json'
require_relative '../app/controllers/users_controller.rb'

RSpec.describe UsersController do
  include Rack::Test::Methods
  before do
    @valid_user = FactoryBot.create(:user)
    @otp_enabled_user = FactoryBot.create(:user)
  end
  let(:valid_email) { 'user@example.com' }
  let(:valid_password) { 'ValidPassword1#' }

  def app
    described_class.new
  end

  def service_class
    AuthenticateUser.new(@valid_user.email, @valid_user.password)
  end

  describe 'POST /signup' do
    let(:valid_params) { { email: Faker::Internet.free_email, password: 'Password@123' } }
    let(:invalid_params) { { email: 'test@example.com', password: 'password@123' } }

    it 'creates a new user and returns success' do
      post '/signup', valid_params.to_json, 'CONTENT_TYPE' => 'application/json'
      response_body = JSON.parse(last_response.body)
      expect(response_body['status']).to eq(200)
      expect(response_body['response']['data']['user']['email']).to eq(valid_params[:email])
      expect(response_body['response']['data']['token']).to be_present
    end

    xit 'returns unprocessable entity if user creation fails' do
      post '/signup', invalid_params.to_json, 'CONTENT_TYPE' => 'application/json'
      response_body = JSON.parse(last_response.body)
      expect(response_body['status']).to eq(422)
      expect(response_body['response']['errors'][0]['password']).to eq(["is invalid"])
    end
  end

  describe 'POST /login' do
    let(:valid_email) { 'user@example.com' }
    let(:valid_password) { 'ValidPassword1#' }

    context 'when authentication is successful without two-factor' do
      xit 'returns success response with token and user details' do
        post '/login', request_body(@valid_user), headers: { 'Content-Type' => 'application/json' }
        response = JSON.parse(last_response.body)
        expect(response['status']).to eq(200)
        expect(response).to include(
          'status' => 'success',
          'token' => anything,
          'user' => hash_including('email' => @valid_user.email, 'two_factor_enabled' => false)
        )
      end
    end

    context 'when authentication is successful with two-factor' do
      xit 'returns success response with OTP information' do
        allow(service_class).to receive(:find_by).with(email: @otp_enabled_user.email).and_return(instance_double(User, two_factor_enabled: true))
        allow(ROTP::TOTP).to receive(:new).and_return(instance_double(ROTP::TOTP, present?: true))

        post '/login', request_body(@otp_enabled_user), headers: { 'Content-Type' => 'application/json' }
        response = JSON.parse(last_response.body)
        expect(response['status']).to eq(200)
        expect(response).to include(
          'status' => 'success',
          'otp' => true
        )
      end
    end

    context 'when user is not found' do
      xit 'returns unprocessable entity with error message' do
        allow(User).to receive(:find_by).with(email: valid_email).and_return(nil)

        post '/login', params: { email: valid_email, password: valid_password, remember_me: false }
        response = JSON.parse(last_response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to include(
          'status' => 'error',
          'errors' => anything
        )
      end
    end

    context 'when authentication fails' do
      xit 'returns unprocessable entity with error message' do
        allow(User).to receive(:find_by).with(email: valid_email).and_return(instance_double(User, authenticate: false))

        post '/login', params: { email: valid_email, password: 'invalid_password', remember_me: false }.to_json, headers: { 'Content-Type' => 'application/json' }
        response = JSON.parse(last_response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to include(
          'status' => 'error',
          'errors' => anything
        )
      end
    end
  end

  describe 'POST /enable_2fa_authentication' do
    before do
      @user = FactoryBot.create(:user, email: Faker::Internet.email, password: 'Password@123', password_confirmation: 'Password@123')
    end

    context 'when user is found' do
      xit 'enables 2FA and returns a QR code' do
        post '/enable_2fa_authentication', { email: @user.email }.to_json

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('image/png')
      end
    end

    context 'when user is not found' do
      xit 'returns an error message' do
        post '/enable_2fa_authentication', { email: 'nonexistent@example.com' }.to_json

        expect(last_response.status).to eq(200)
        response_json = JSON.parse(last_response.body)
        expect(response_json['status']).to eq('error')
        expect(response_json['message']).to eq('User not found')
      end
    end
  end

  def request_body(user)
    {
      email: user.email,
      password: user.password,
      remember_me: false
    }.to_json
  end
end

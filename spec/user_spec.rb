# spec/models/user_spec.rb

require 'spec_helper'
require 'bcrypt'
require 'faker'
require "pony"

describe User do
  let(:valid_email) { 'user@example.com' }
  let(:valid_password) { 'Password1#' }

  describe 'validations' do
    context 'when creating a new user' do
      it 'is valid with a valid email and password' do
        user = User.new(email: Faker::Internet.email, password: valid_password, password_confirmation: valid_password)
        expect(user).to be_valid
      end

      it 'is invalid without an email' do
        user = User.new(password: valid_password)
        expect(user).to_not be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it 'is invalid without a password' do
        user = User.new(email: valid_email)
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end

      it 'is invalid with an invalid email format' do
        user = User.new(email: 'invalid_email', password: valid_password)
        expect(user).to_not be_valid
        expect(user.errors[:email]).to include(I18n.t('errors.validation_failed'))
      end

      it 'is invalid with a password that does not meet the requirements' do
        user = User.new(email: Faker::Internet.email, password: 'weakpassword')
        expect(user).to_not be_valid
      end

      it 'is invalid if email is not unique' do
        existing_user = User.create(email: valid_email, password: valid_password)
        user = User.new(email: valid_email, password: 'DifferentPassword1#')
        expect(user).to_not be_valid
        expect(user.errors[:email]).to include('has already been taken')
      end
    end

    context 'when updating the password' do
      let(:user) { User.create(email: Faker::Internet.email, password: valid_password) }

      it 'is valid with a new valid password' do
        user.password = 'NewPassword2$'
        expect(user).to be_valid
      end

      it 'is invalid with a new weak password' do
        user.update_password('weakpassword')
        expect(user).to_not be_valid
      end
    end
  end

  describe 'methods' do
    let(:user) { User.create(email: valid_email, password: valid_password) }

    it 'updates the password successfully' do
      new_password = 'NewPassword3#'
      user.update_password(new_password)
      expect(user.authenticate(new_password)).to eq(user)
    end

    it 'sends a welcome email after creation' do
      allow(Pony).to receive(:mail)
      user = User.create(email: Faker::Internet.email, password: 'NewUser1#')
      expect(Pony).to have_received(:mail).with({body: "Congratulation! You have sucessfully sing up", subject: "Welcome to App", to: user.email})
    end
  end
end

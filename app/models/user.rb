# models/user.rb

require 'sinatra/activerecord'
require 'bcrypt'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require_all 'app/**/*.rb'

class User < ActiveRecord::Base
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true,
                       format: { with: /\A(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]]) /x }, if: :apply_password_validation?
  validate :validate_email_format
  mount_uploader :qr_code, ImageUploader
  after_create :send_welcome_email

  def validate_email_format
    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    return if email_regex.match?(email)

    errors.add(:email, I18n.t(errors.invalid_format))
  end

  def send_welcome_email
    Pony.mail(to: email, subject: 'Welcome to App', body: 'Congratulation! You have sucessfully sing up')
  end

  def update_password(new_password)
    self.password = new_password
    save
  end

  def apply_password_validation?
    new_record? || password_digest_changed?
  end
end

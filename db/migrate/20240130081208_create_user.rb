# db/migrate/create_user.rb

class CreateUser < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :otp_secret
      t.string :qr_code
      t.boolean :two_factor_enabled, default: false
      t.boolean :remember_me, default: false
      t.datetime :last_login
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end

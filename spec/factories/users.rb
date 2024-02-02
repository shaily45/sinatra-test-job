FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'Password@123' }
  end
end

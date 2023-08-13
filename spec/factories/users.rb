require 'faker'

FactoryBot.define do
    factory :user do
        full_name { Faker::Name.name }
        user_name { Faker::Internet.username }
        email { Faker::Internet.email }
        password { 'password123' }
        password_confirmation { 'password123'}
        account_pending { true }
    end
end

FactoryBot.define do
  factory :transaction do
    sender_id { 1 }
    receiver_id { 1 }
    amount { "9.99" }
    status { "MyString" }
  end
end

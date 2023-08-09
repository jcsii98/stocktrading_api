FactoryBot.define do
  factory :portfolio do
    stock_id { "MyString" }
    quantity { 1 }
    price { 1 }
    user { nil }
  end
end

FactoryBot.define do
  factory :portfolio do
    stock_id { "mock_id" }
    quantity { 100000 }
    price { 1 }
    user { nil }
  end
end

FactoryBot.define do
  factory :portfolio do
    stock_symbol { "aaave" }
    quantity { 100000 }
    price { 1 }
    user { nil }
  end
end

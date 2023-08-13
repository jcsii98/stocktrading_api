FactoryBot.define do
  factory :transaction do
    seller_portfolio_id { 1 }
    buyer_portfolio_id { 2 }
    status { "pending" }
    quantity { 1000 }
  end
end

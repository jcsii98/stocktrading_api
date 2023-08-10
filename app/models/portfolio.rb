class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :buyer_transactions, class_name: 'Transaction', foreign_key: 'buyer_portfolio_id'
  has_many :seller_transactions, class_name: 'Transaction', foreign_key: 'seller_portfolio_id'
  validates :stock_id, uniqueness: { scope: :user_id, message: "Stock already exists in portfolio for this user" }

  
end

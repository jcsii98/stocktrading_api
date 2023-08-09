class Portfolio < ApplicationRecord
  belongs_to :user

  validates :stock_id, uniqueness: { scope: :user_id, message: "Stock already exists in portfolio for this user" }

  
end

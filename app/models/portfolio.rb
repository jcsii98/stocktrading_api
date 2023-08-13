class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :buyer_transactions, class_name: 'Transaction', foreign_key: 'buyer_portfolio_id'
  has_many :seller_transactions, class_name: 'Transaction', foreign_key: 'seller_portfolio_id'
  validates :stock_id, uniqueness: { scope: :user_id, message: "portfolio already exists for this stock" }
  validate :positive_quantity
  
  
  def positive_quantity
    if quantity.blank? || quantity.to_f < 0
      errors.add(:quantity, "must be a positive number")
      Rails.logger.debug("Validation failed: quantity=#{quantity}")
    end
  end
  
end

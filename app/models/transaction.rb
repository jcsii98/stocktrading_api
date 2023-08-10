class Transaction < ApplicationRecord
    belongs_to :buyer_portfolio, class_name: 'Portfolio', foreign_key: 'buyer_portfolio_id'
    belongs_to :seller_portfolio, class_name: 'Portfolio', foreign_key: 'seller_portfolio_id'

    validates :seller_portfolio, :buyer_portfolio, :amount, presence: true
    validate :different_users
    validate :positive_amount

    private

    def different_users
        errors.add(:buyer_portfolio_id, "can't be the same as the seller") if seller_portfolio_id == buyer_portfolio_id
    end

    def positive_amount
        errors.add(:amount, "must be positive") if amount <= 0
    end
end

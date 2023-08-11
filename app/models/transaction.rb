class Transaction < ApplicationRecord
    belongs_to :buyer_portfolio, class_name: 'Portfolio', foreign_key: 'buyer_portfolio_id'
    belongs_to :seller_portfolio, class_name: 'Portfolio', foreign_key: 'seller_portfolio_id'

    validates :seller_portfolio, :buyer_portfolio, :quantity, presence: true
    validate :different_users
    validate :positive_quantity

    private

    def different_users
        errors.add(:buyer_portfolio_id, "can't be the same as the seller") if seller_portfolio_id == buyer_portfolio_id
    end

    def positive_quantity
        if quantity.blank? || quantity.to_f <= 0
            errors.add(:quantity, "must be a positive number")
        end
    end
end

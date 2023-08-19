class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :buyer_transactions, class_name: 'Transaction', foreign_key: 'buyer_portfolio_id'
  has_many :seller_transactions, class_name: 'Transaction', foreign_key: 'seller_portfolio_id'
  validates :stock_id, presence: true, uniqueness: { scope: :user_id, message: "portfolio already exists for this stock" }
  validate :positive_quantity
  before_save :update_price
  
  def positive_quantity
    if quantity.blank? || quantity.to_f < 0
      errors.add(:quantity, "must be a positive number")
      Rails.logger.debug("Validation failed: quantity=#{quantity}")
    end
  end
  
  def update_portfolios_total_amount
    # Calculate total_amount based on the updated quantity and price
    self.total_amount = self.price * self.quantity
  end
  
  # on transaction.create

  def self.check_buyer_portfolio(user, stock_id)
    buyer_portfolio = user.portfolios.find_by(stock_id: stock_id)
    if buyer_portfolio.nil?
      return { success: false, message: "Portfolio with stock_id '#{stock_id}' must exist for the current user"}
    else
      return { success: true, buyer_portfolio: buyer_portfolio }
    end
  end

  def self.check_seller_portfolio(seller_portfolio, transaction_quantity)
    if transaction_quantity > seller_portfolio.quantity
      return { success: false, message: "Insufficient portfolio quantity for the transaction" }
    else
      return { success: true }
    end
  end
  

  # after transaction.approve

  def update_portfolios_after_transaction(transaction)
    stocks_service = StocksService.new

    buyer_portfolio = transaction.buyer_portfolio
    Rails.logger.debug("Updating portfolios after transaction #{transaction.id} with quantity: #{transaction.quantity}")
    Rails.logger.debug("seller quantity before #{quantity}")
    new_seller_quantity = quantity - transaction.quantity
    Rails.logger.debug("seller quantity after #{new_seller_quantity}")
    Rails.logger.debug("buyer quantity before #{buyer_portfolio.quantity}")
    new_buyer_quantity = buyer_portfolio.quantity + transaction.quantity
    Rails.logger.debug("buyer quantity after #{new_buyer_quantity}")
    
    stock_price = stocks_service.fetch_stock_price(transaction.stock_id)
    new_price = stock_price

    new_seller_amount = new_seller_quantity.to_f * new_price.to_f
    new_buyer_amount = new_buyer_quantity.to_f * new_price.to_f

    update(quantity: new_seller_quantity, price: new_price, total_amount: new_seller_amount)
    buyer_portfolio.update(quantity: new_buyer_quantity, price: new_price, total_amount: new_buyer_amount)

    Rails.logger.debug("Updating portfolios after transaction #{transaction.id}")
  end
  
  private

  def update_price
    stocks_service = StocksService.new
    self.price = stocks_service.fetch_stock_price(stock_id)
  end

end

class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :buyer_transactions, class_name: 'Transaction', foreign_key: 'buyer_portfolio_id'
  has_many :seller_transactions, class_name: 'Transaction', foreign_key: 'seller_portfolio_id'
  validates :stock_id, presence: true, uniqueness: { scope: :user_id, message: "portfolio already exists for this stock" }
  validate :positive_quantity
  
  
  def positive_quantity
    if quantity.blank? || quantity.to_f < 0
      errors.add(:quantity, "must be a positive number")
      Rails.logger.debug("Validation failed: quantity=#{quantity}")
    end
  end
  
  # on transaction.create

  def self.check_buyer_portfolio(user, stock_id)
    buyer_portfolio = user.portfolios.find_by(stock_id: stock_id)
    if buyer_portfolio.nil?
      return { sucess: false, message: "Portfolio with stock_id '#{stock_id}' must exist for the current user"}
    else
      return { success: true, buyer_portfolio: buyer_portfolio }
    end
  end

  def self.check_seller_portfolio(seller_portfolio, transaction_quantity)
    if transaction_quantity > seller_portfolio.quantity
      return { success: false, message: "insufficient portfolio quantity for the transaction" }
    else
      return { success: true }
    end
  end
  

  # after transaction.approve

  def update_portfolios_after_transaction(transaction)
    buyer_portfolio = transaction.buyer_portfolio
    Rails.logger.debug("Updating portfolios after transaction #{transaction.id} with quantity: #{transaction.quantity}")
    Rails.logger.debug("seller quantity before #{quantity}")
    new_seller_quantity = quantity - transaction.quantity
    Rails.logger.debug("seller quantity after #{new_seller_quantity}")
    Rails.logger.debug("buyer quantity before #{buyer_portfolio.quantity}")
    new_buyer_quantity = buyer_portfolio.quantity + transaction.quantity
    Rails.logger.debug("buyer quantity after #{new_buyer_quantity}")
    
    stock_price = fetch_stock_price_from_api(transaction.stock_id)
    new_price = stock_price[:usd]

    new_seller_amount = new_seller_quantity.to_f * new_price.to_f
    new_buyer_amount = new_buyer_quantity.to_f * new_price.to_f

    update(quantity: new_seller_quantity, price: new_price, total_amount: new_seller_amount)
    buyer_portfolio.update(quantity: new_buyer_quantity, price: new_price, total_amount: new_buyer_amount)

    Rails.logger.debug("Updating portfolios after transaction #{transaction.id}")
  end
  
  private

  def fetch_stock_price_from_api(stock_id)
    response = RestClient.get "https://api.coingecko.com/api/v3/coins/#{stock_id}?tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false"
    json_response = JSON.parse(response.body)

    stock_price = {
      usd: json_response['market_data']['current_price']['usd']
    }

    return stock_price
  end

end

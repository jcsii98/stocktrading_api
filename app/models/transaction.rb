class Transaction < ApplicationRecord
    belongs_to :buyer_portfolio, class_name: 'Portfolio', foreign_key: 'buyer_portfolio_id'
    belongs_to :seller_portfolio, class_name: 'Portfolio', foreign_key: 'seller_portfolio_id'

    validates :seller_portfolio, :buyer_portfolio, :quantity, presence: true

    after_update :update_portfolios_quantity, :update_user_wallet
    
    def self.check_valid_entry(user, portfolio_id, quantity)
        Rails.logger.debug("check_valid_entry: Received quantity: #{quantity}")

        stocks_service = StocksService.new
        
        different_users_check = validate_different_users(user, portfolio_id)
        return different_users_check if different_users_check

        positive_quantity_check = validate_positive_quantity(quantity)
        return positive_quantity_check if positive_quantity_check

        seller_portfolio = Portfolio.find(portfolio_id)
        transaction_stock = seller_portfolio.stock
        buyer_portfolio = user.portfolios.find_by(stock_id: transaction_stock.id)

        stock_price = transaction_stock.usd

        transaction_quantity = quantity.to_f
        amount = transaction_quantity * stock_price

        # Validation methods return error messages or nil if successful
        buyer_portfolio_check = validate_buyer_portfolio(user, transaction_stock)
        return buyer_portfolio_check if buyer_portfolio_check

        cover_result = validate_covering_pending_amount(user, amount)
        return cover_result if cover_result

        seller_portfolio_check = validate_seller_portfolio(seller_portfolio, transaction_quantity)
        return seller_portfolio_check if seller_portfolio_check

        # If all validations pass, return a success hash
        # update pending amount
        user.add_pending_amount(amount)
        {
        success: true,
        seller_portfolio: seller_portfolio,
        buyer_portfolio: buyer_portfolio,
        transaction_stock_id: transaction_stock.id,
        stock_price: stock_price,
        amount: amount
        }
    end

    private

    # creation validations

    def self.validate_different_users(user, portfolio_id)
        seller_portfolio = Portfolio.find_by(id: portfolio_id)
        if !seller_portfolio
            { success: false, message: "Seller portfolio does not exist" }
        elsif seller_portfolio.user_id == user.id 
            { success: false, message: "Buyer cannot be the same as the seller" }
        end
    end
    
    def self.validate_positive_quantity(quantity)
        Rails.logger.debug("Positive quantity validation called with quantity: #{quantity}")

        { success: false, message: "Quantity must be a positive number" } if quantity.nil? || quantity.to_s.empty? || quantity.to_f <= 0
    end

    def self.validate_buyer_portfolio(user, stock_id)
        buyer_portfolio = user.portfolios.find_by(stock_id: stock_id)
        { success: false, message: "Portfolio with stock_id '#{stock_id}' must exist for the current user" } unless buyer_portfolio
    end

    def self.validate_covering_pending_amount(user, amount)
        cover_result = user.can_cover_resulting_pending_amount(amount)
        { success: false, message: cover_result[:message] } unless cover_result[:success]
    end

    def self.validate_seller_portfolio(seller_portfolio, transaction_quantity)
        { success: false, message: 'Insufficient portfolio quantity for the transaction' } if transaction_quantity > seller_portfolio.quantity
    end
  
    # callbacks

    def update_portfolios_quantity
        Rails.logger.debug("Transaction status: #{status}")
        return unless status == 'approved'

        Rails.logger.debug("Updating portfolios after approval")
        seller_portfolio.update_portfolios_after_transaction(self)
    end

    def update_user_wallet
        Rails.logger.debug("Transaction status: #{status}")
        return unless status == 'approved'

        Rails.logger.debug("Updating wallets after approval")
        update_buyer_and_seller_wallets
    end

    def update_buyer_and_seller_wallets
        buyer_user = buyer_portfolio.user
        seller_user = seller_portfolio.user
        transaction_amount = amount

        buyer_user.update_wallet_balance(transaction_amount, :subtract)
        seller_user.update_wallet_balance(transaction_amount, :add)
    end

end
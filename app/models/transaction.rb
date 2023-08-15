class Transaction < ApplicationRecord
    belongs_to :buyer_portfolio, class_name: 'Portfolio', foreign_key: 'buyer_portfolio_id'
    belongs_to :seller_portfolio, class_name: 'Portfolio', foreign_key: 'seller_portfolio_id'

    validates :seller_portfolio, :buyer_portfolio, :quantity, presence: true
    validate :different_users
    validate :positive_quantity

    after_update :update_portfolios_quantity, :update_user_wallet
    
    def self.create_transaction(user, portfolio_id, quantity)
        seller_portfolio = Portfolio.find(portfolio_id)
        transaction_stock_id = seller_portfolio.stock_id
        buyer_portfolio = user.portfolios.find_by(stock_id: transaction_stock_id)

        stock_price = new.fetch_stock_price_from_api(transaction_stock_id)
        price = stock_price[:usd]
        amount = quantity.to_f * price.to_f

        if buyer_portfolio.nil?
            return { success: false, message: "Portfolio with stock_id '#{transaction_stock_id}' must exist for the current user" }
        elsif user.wallet_balance < amount
            insufficient_amount = user.wallet_balance - amount
            return { success: false, message: "Not enough funds, please top up '#{insufficient_amount}'" }
        elsif quantity.to_f > seller_portfolio.quantity
            return { success: false, message: 'Insufficient portfolio quantity for the transaction' }
        else
            return {
                success: true,
                seller_portfolio: seller_portfolio,
                buyer_portfolio: buyer_portfolio,
                transaction_stock_id: transaction_stock_id,
                stock_price: stock_price,
                price: price,
                amount: amount
            }
        end
    end

    def fetch_stock_price_from_api(stock_id)
        response = RestClient.get "https://api.coingecko.com/api/v3/coins/#{stock_id}?tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false"
        json_response = JSON.parse(response.body)

        stock_price = {
        usd: json_response['market_data']['current_price']['usd']
        }

        return stock_price
    end
    private

  
    def update_portfolios_quantity
        Rails.logger.debug("Transaction status: #{status}")
        if status == 'approved'
            Rails.logger.debug("Updating portfolios after approval")
            seller_portfolio.update_portfolios_after_transaction(self)
        end
    end

    def update_user_wallet
        Rails.logger.debug("Transaction status: #{status}")
        if status == 'approved'
            Rails.logger.debug("Updating wallets after approval")
                buyer_user = buyer_portfolio.user
                seller_user = seller_portfolio.user

                transaction_amount = self.amount 

                buyer_user.update_wallet_balance(transaction_amount, :subtract)
                seller_user.update_wallet_balance(transaction_amount, :add)
        end
    end
    
    def different_users
        errors.add(:buyer_portfolio_id, "can't be the same as the seller") if seller_portfolio_id == buyer_portfolio_id
    end

    def positive_quantity
        if quantity.blank? || quantity.to_f <= 0
            errors.add(:quantity, "must be a positive number")
        end
    end



end

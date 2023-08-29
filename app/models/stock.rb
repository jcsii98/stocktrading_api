class Stock < ApplicationRecord
  has_many :portfolios

  after_update :update_portfolios_price

  def update_portfolios_price
      portfolios.each do |portfolio|
        portfolio.update_price_from_stock
        Rails.logger.debug("Portfolio price updated for portfolio ID: #{portfolio.id}")
      end
  end

  def self.fetch_and_update_stock_data

    stocks_service = StocksService.new
    
    available_stocks = stocks_service.fetch_available_stocks
    
    available_stocks.each do |stock_data|
      symbol = stock_data[:symbol]
      name = stock_data[:name]
      usd = stock_data[:usd]  # Use 'current_price' field for USD
      
      unless symbol.present?
        puts "Skipped stock with missing symbol"
        next
      end
      
      stock = find_or_create_by(symbol: symbol)
      
      if stock.update(name: name, usd: usd)
        puts "Updated stock: #{symbol}, Name: #{name}, USD: #{usd}"
      else
        puts "Failed to update stock: #{symbol}"
      end
    end
  end


end

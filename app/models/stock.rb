class Stock < ApplicationRecord
  has_many :portfolios
  def self.fetch_and_update_stock_data
    available_stocks = StocksService.new.fetch_available_stocks
    
    available_stocks.each do |stock_data|
      symbol = stock_data[:symbol]
      name = stock_data[:name]
      usd = stock_data[:usd]  # Use the 'current_price' field for USD
      
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

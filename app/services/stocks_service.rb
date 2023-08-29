require 'httparty'

class StocksService


  def fetch_available_stocks
    response = HTTParty.get("http://phisix-api4.appspot.com/stocks.json")

    if response.success?
      stocks_data = JSON.parse(response.body)
      stocks_mapped = stocks_data['stock'].map do |stock_data|
        {
          symbol: stock_data['symbol'],
          name: stock_data['name'],
          usd: stock_data['price']['amount']
        }
      end
    else
      []
    end
  end
    
end


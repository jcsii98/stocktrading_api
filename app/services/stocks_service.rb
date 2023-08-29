require 'httparty'

class StocksService
  def initialize
    @base_url = 'https://finnhub.io/api/v1'
    @api_key = 'cjmtue1r01qmdd9q6m40cjmtue1r01qmdd9q6m4g' 
  end

  def fetch_available_stocks
    response = HTTParty.get("#{@base_url}/stock/symbol?exchange=US&token=#{@api_key}")

    if response.success?
      stocks_data = JSON.parse(response.body)
      stocks_data.map do |stock_data|
        {
          symbol: stock_data['symbol'],
          name: stock_data['description'],
          usd: fetch_stock_price(stock_data['symbol'])
        }
      end
    else
      []
    end
  end

  private

  def fetch_stock_price(symbol)
    response = HTTParty.get("#{@base_url}/quote?symbol=#{symbol}&token=#{API_KEY}")

    if response.success?
      stock_price_data = JSON.parse(response.body)
      stock_price_data['c']
    else
      nil
    end
  end
    
end
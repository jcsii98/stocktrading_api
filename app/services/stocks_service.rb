class StocksService

  def fetch_available_stocks
    response = RestClient.get 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&category=aave-tokens&order=market_cap_desc&per_page=100&page=1&sparkline=false&locale=en'
    json_response = JSON.parse(response.body)
        
    # Extract relevant data from the JSON response, for example:
    available_stocks = json_response.map { |stock| { id: stock['id'], name: stock['name'], symbol: stock['symbol'], usd: stock['current_price'] } }
    return available_stocks
  end

    
end
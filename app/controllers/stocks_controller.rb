class StocksController < ApplicationController
    def index
        @stocks = Stock.all
        render json: { data: @stocks }
    end

    def update_stocks
        Stock.fetch_and_update_stock_data
        render json: { message: 'Stock data updated' }
    end

    # test api call
    
    def fetch_coin_data
    response = RestClient.get("https://api.coingecko.com/api/v3/coins/markets", 
                              params: {
                                vs_currency: 'usd',
                                category: 'aave-tokens',
                                order: 'market_cap_desc',
                                per_page: 100,
                                page: 1,
                                sparkline: false,
                                locale: 'en'
                              })

    coin_data = JSON.parse(response.body)
    render json: { coin_data: coin_data }
  rescue RestClient::ExceptionWithResponse => e
    render json: { error: e.message }, status: e.response.code
  end

end

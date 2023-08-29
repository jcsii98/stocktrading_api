class StocksController < ApplicationController
    def index
        @stocks = Stock.all
        render json: { data: @stocks }
    end

    def update_stocks
        Stock.fetch_and_update_stock_data
        render json: { message: 'Stock data updated' }
    end

    # bomy url "https://api.coingecko.com/api/v3/coins/markets?vs_currency=php&order=market_cap_desc&per_page=250&page=1&sparkline=false&locale=en"
    def test_rest
        response = RestClient.get("https://finnhub.io/api/v1/stock/symbol?exchange=US", 
        # response = RestClient.get("https://api.coingecko.com/api/v3/coins/markets", 
                                # params: {
                                #     vs_currency: 'usd',
                                #     category: 'aave-tokens',
                                #     order: 'market_cap_desc',
                                #     per_page: 100,
                                #     page: 1,
                                #     sparkline: false,
                                #     locale: 'en',

                                #     },
                                # headers: {
                                #         'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36'
                                #     }
        )

        coin_data = JSON.parse(response.body)
        render json: { coin_data: coin_data }
    #   rescue RestClient::ExceptionWithResponse => e
    #     render json: { error: e.message }, status: e.response.code
    end

    def test_party
        response = HTTParty.get("https://finnhub.io/api/v1/stock/symbol?exchange=US", 

        )

        coin_data = JSON.parse(response.body)
        render json: { coin_data: coin_data }
    end

end

require 'rest-client'

class StocksController < ApplicationController
    before_action :authenticate_user!

    def available_stocks
        available_stocks = fetch_available_stocks_from_api

        render json: available_stocks
        # response structure:
        # [
        #     {
        #         "id": "01coin",
        #         "name": "01coin",
        #         "symbol": "zoc"
        #     }
        # ]
    end

    def stock_details
        stock_id = params[:id]

        stock_details = fetch_stock_details_from_api(stock_id)

        render json: stock_details
    end


    private

    def fetch_stock_details_from_api(stock_id)
        api_url = "https://api.coingecko.com/api/v3/coins/#{stock_id}?tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false"
        response = RestClient.get(api_url)
        json_response = JSON.parse(response.body)

        stock_details = {
            id: json_response['id'],
            name: json_response['name'],
            symbol: json_response['symbol'],
            usd: json_response['market_data']['current_price']['usd']
        }

        return stock_details
    end

    def fetch_available_stocks_from_api
        response = RestClient.get 'https://api.coingecko.com/api/v3/coins/list'
        json_response = JSON.parse(response.body)
        
        # Extract relevant data from the JSON response, for example:
        available_stocks = json_response.map { |stock| { id: stock['id'], name: stock['name'], symbol: stock['symbol'] } }
        return available_stocks
    end
    
end

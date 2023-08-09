require 'rest-client'

class StocksController < ApplicationController
    def available_stocks
        available_stocks = fetch_available_stocks_from_api

        render json: available_stocks
    end

    private

    def fetch_available_stocks_from_api
        response = RestClient.get 'https://api.coingecko.com/api/v3/coins/list'
        json_response = JSON.parse(response.body)
        
        # Extract relevant data from the JSON response, for example:
        available_stocks = json_response.map { |stock| { id: stock['id'], name: stock['name'], symbol: stock['symbol'] } }
        return available_stocks
    end
end

class StocksController < ApplicationController
    def index
        @stocks = Stock.all
        render json: { data: @stocks }
    end
end

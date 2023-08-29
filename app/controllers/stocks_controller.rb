class StocksController < ApplicationController
  def index
    @stocks = Stock.all
    render json: { data: @stocks }
  end

  def update
    Stock.fetch_and_update_stock_data
    render json: { message: 'Stock data updated' }
  end

end

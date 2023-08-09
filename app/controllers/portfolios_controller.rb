class PortfoliosController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_approved, only: [:controlleractionhere]

    def new
        
    end

    def create
        @portfolio = current_user.portfolios.build(portfolio_params)

        fetched_price = fetch_price_from_api(@portfolio.stock_id)

        @portfolio.price = fetched_price

        @portfolio.total_amount = @portfolio.calculate_total_amount

        if @portfolio.save
            render json: { status: 'success', data: @portfolio }, status: :created
        else
            render json: { status: 'error', errors: @portfolio.errors.full_messages }, status: :unprocessable_entity
        end

    end

    



    private
    
    def fetch_price_from_api(stock_id)
  # Use your code here to fetch the price from the API based on the stock_id
  # For example, you might use a HTTP request library like RestClient or Faraday
  # and parse the response to extract the price.
    end

    def calculate_total_amount
        self.quantity * self.price
    end

    def verify_approved
        if current_user.account_pending
            render json: { data: { message: "User is pending approval" } }, status: :unprocessable_entity
        else
            return true
        end
    end

    def portfolio_params
        params.require(:portfolio).permit(:stock_id, :quantity)
    end

end

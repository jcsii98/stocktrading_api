class PortfoliosController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_approved, only: [:controlleractionhere]
    before_action :set_portfolio, only: [:show, :update, :destroy]

    def index
        @portfolios = current_user.portfolios
        render json: { data: @portfolios }
    end

    def create
        @portfolio = current_user.portfolios.build(portfolio_params)

        fetched_price = fetch_price_from_api(@portfolio.stock_id)

        @portfolio.price = fetched_price

        total_amount = @portfolio.price * @portfolio.quantity

        @portfolio.total_amount = total_amount

        if @portfolio.save

            render json: { status: 'success', data: @portfolio }, status: :created
        else
            render json: { status: 'error', errors: @portfolio.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def show

    end
    
    def update
    
    end

    def destroy
        if @portfolio.destroy
            render json: { status: 'success', message: 'Portfolio successfully deleted' }
        else
            render son: { errors: @portfolios.errors.full_messages }, status: unprocessable_entity
        end
    end





    private
    
    def fetch_price_from_api(stock_id)
        response = RestClient.get 'https://api.coingecko.com/api/v3/coins/01coin?tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false' 
        json_response = JSON.parse(response.body)

        stock_details = {
            id: json_response['id'],
            name: json_response['name'],
            symbol: json_response['symbol'],
            usd: json_response['market_data']['current_price']['usd']
        }

        return stock_details[:usd]
    end

    def set_portfolio
        @portfolio = current_user.portfolios.find(params[:id])
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
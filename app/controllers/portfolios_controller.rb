class PortfoliosController < ApplicationController
    before_action :authenticate_user!, only: [:create, :destroy]
    before_action :verify_approved, only: [:create, :destroy, :update]
    before_action :set_portfolio, only: [:show, :update, :destroy]
    before_action :authenticate_admin!, only: [:index_by_user]

    def index
            @portfolios = current_user.portfolios
            render json: { data: @portfolios }
    end

    def index_by_stock
        stock_id = params[:stock_id]
        @portfolios = Portfolio.where(stock_id: stock_id)

        render json: { data: @portfolios }
    end

    def index_by_user
        user_id = params[:user_id]
        @portfolios = Portfolio.where(user_id: user_id)

        render json: { data: @portfolios }
    end

    def create
        @portfolio = current_user.portfolios.build(portfolio_params)

        available_stocks = verify_available_stock(@portfolio.stock_id)
        matching_stock = available_stocks.find { |stock| stock[:id] == @portfolio.stock_id }

        if matching_stock.nil?
            render json: { status: 'error', message: 'Invalid stock_id' }, status: :unprocessable_entity
            return
        end

        fetched_price = fetch_price_from_api(@portfolio.stock_id)

        if fetched_price.nil?
            render json: { status: 'error', message: 'Price cannot be fetched' }, status: :unprocessable_entity
            return
        end

        @portfolio.price = fetched_price

        @portfolio.quantity ||= 0

        total_amount = @portfolio.price * @portfolio.quantity

        @portfolio.total_amount = total_amount

        if @portfolio.save

            render json: { status: 'success', data: @portfolio }, status: :created
        else
            render json: { status: 'error', errors: @portfolio.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def show
        render json: @portfolio
    end

    def update
        if @portfolio.update(portfolio_params)
            # Calculate total_amount based on the updated quantity and price
            @portfolio.total_amount = @portfolio.price * @portfolio.quantity
            @portfolio.save

            render json: { status: 'success', data: @portfolio }
        else
            render json: { status: 'error', errors: @portfolio.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        if @portfolio.destroy
            render json: { status: 'success', message: 'Portfolio successfully deleted' }
        else
            render son: { errors: @portfolios.errors.full_messages }, status: unprocessable_entity
        end
    end


    private

    def verify_available_stock(stock_id)
        response = RestClient.get 'https://api.coingecko.com/api/v3/coins/list'
        json_response = JSON.parse(response.body)
        
        # Extract relevant data from the JSON response, for example:
        available_stocks = json_response.map { |stock| { id: stock['id'], name: stock['name'], symbol: stock['symbol'] } }
        return available_stocks
    end
    
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

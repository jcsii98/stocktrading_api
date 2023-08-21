class PortfoliosController < ApplicationController
    before_action :authenticate_user!, only: [:index, :create, :destroy]
    before_action :verify_approved, only: [:create, :destroy, :update]
    before_action :set_portfolio, only: [:update, :destroy]
    before_action :authenticate_admin!, only: [:index_by_user, :index_by_stock_id]
    before_action :authorize_access, only: [:update]

    def index
            @portfolios = current_user.portfolios

            if @portfolios.empty?
                render json: { message: 'No portfolios found for current_user' }
            else
            render json: { data: @portfolios }
            end
    end

    def index_by_stock_id
        portfolios = PortfoliosService.index_by_stock_id(params[:stock_id])
        render json: { data: portfolios }
    end

    def index_by_user
        portfolios = PortfoliosService.index_by_user(params[:user_id])
        render json: { data: portfolios }
    end

    def create
        @portfolio = current_user.portfolios.build(portfolio_params)


        stocks_service = StocksService.new
        available_stocks = stocks_service.fetch_available_stocks
        matching_stock = available_stocks.find { |stock| stock[:id] == @portfolio.stock_id }

        if matching_stock.nil?
            render json: { status: 'error', message: 'Invalid stock_id' }, status: :unprocessable_entity
            return
        end

        fetched_price = stocks_service.fetch_stock_price(@portfolio.stock_id)

        if fetched_price.nil?
            render json: { status: 'error', message: 'Price cannot be fetched' }, status: :unprocessable_entity
            return
        end

        @portfolio.price = fetched_price.to_d

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
        portfolio = Portfolio.find(params[:id])

        render json: { status: 'success', data: portfolio }, status: :ok
        rescue ActiveRecord::RecordNotFound
        render json: { status: 'error', message: 'Portfolio not found' }, status: :not_found
    end

    def update
        if @portfolio.update(portfolio_params)
            @portfolio.update_portfolios_total_amount
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

    def authorize_access
        authorize_portfolio_owner
    end

    def authorize_portfolio_owner
        portfolio = Portfolio.find(params[:id])
        unless portfolio.user == current_user
            render json: { status: 'error', message: 'You are not authorized to access this resource.'}, status: :forbidden
        end
        rescue ActiveRecord::RecordNotFound
            render json: { status: 'error', message: 'Portfolio not found.' }, status: :not_found
    end

end

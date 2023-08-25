class PortfoliosController < ApplicationController
    # before_action :authenticate_user!, only: [:index, :create, :destroy]
    # before_action :verify_approved, only: [:create, :destroy, :update]
    # before_action :set_portfolio, only: [:update, :destroy]
    # before_action :authorize_access, only: [:update]

    def index
            @portfolios = current_user.portfolios

            if @portfolios.empty?
                render json: { message: 'No portfolios found for current_user' }
            else
            render json: { data: @portfolios }
            end
    end

    def index_by_stock_symbol
        portfolios = PortfoliosService.index_by_stock_symbol(params[:stock_symbol])
        render json: { data: portfolios }
    end

    def index_by_user
        portfolios = PortfoliosService.index_by_user(params[:user_id])
        render json: { data: portfolios }
    end

    def create
        portfolio_creator = PortfolioCreator.new(current_user, portfolio_params)
        if portfolio_creator.create_portfolio
            render json: { status: 'success', data: portfolio_creator.portfolio }, status: :created
        else
            render json: { status: 'error', errors: portfolio_creator.portfolio.errors.full_messages }, status: :unprocessable_entity
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
        params.require(:portfolio).permit(:stock_symbol, :quantity)
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

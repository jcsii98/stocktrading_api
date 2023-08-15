class TransactionsController < ApplicationController
    before_action :authorize_access, only: [:index, :show]
    before_action :authenticate_user!, only: [:create]
    
    def index
        portfolio = Portfolio.find(params[:portfolio_id])
        buyer_transactions = portfolio.buyer_transactions
        seller_transactions = portfolio.seller_transactions

        render json: { status: 'success', buyer_transactions: buyer_transactions, seller_transactions: seller_transactions }, status: :ok
    end

    def show
      transaction = Transaction.find(params[:id])

      render json: { status: 'success', data: transaction }, status: :ok
    end

    def create
      transaction_data = Transaction.create_transaction(current_user, params[:portfolio_id], params[:quantity])

      if transaction_data[:success]
        transaction = Transaction.new(
          buyer_portfolio_id: transaction_data[:buyer_portfolio].id,
          seller_portfolio_id: transaction_data[:seller_portfolio].id,
          amount: transaction_data[:amount],
          price: transaction_data[:price],
          quantity: params[:quantity],
          status: 'pending',
          stock_id: transaction_data[:transaction_stock_id]
        )

        if transaction.save
          render json: { status: 'success', data: transaction }, status: :created
        else
          render json: { status: 'error', errors: transaction.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { status: 'error', message: transaction_data[:message] }, status: :unprocessable_entity
      end
    end

    def update
      begin
        portfolio = current_user.portfolios.find(params[:portfolio_id])
        transaction = portfolio.seller_transactions.find(params[:id])
        
        if transaction.status == 'approved'
          render json: { status: 'error', message: 'Transaction is already approved' }, status: :unprocessable_entity
          return
        end

        if transaction.update(status: 'approved')

          render json: { status: 'success', message: 'Transaction approved successfully' }, status: :ok
        else
          render json: { status: 'error', message: transaction.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { status: 'error', message: 'Transaction not found or unauthorized' }, status: :not_found
      end
    end

  private

  def fetch_stock_price_from_api(stock_id)
    response = RestClient.get "https://api.coingecko.com/api/v3/coins/#{stock_id}?tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false"
    json_response = JSON.parse(response.body)

    stock_price = {
      usd: json_response['market_data']['current_price']['usd']
    }

    return stock_price
  end
  
  def authorize_access
    authorize_portfolio_owner
  end
  
  def authorize_portfolio_owner
    portfolio = Portfolio.find(params[:portfolio_id])
    unless portfolio.user == current_user
        render json: { status: 'error', message: 'You are not authorized to access this resource.'}, status: :forbidden
    end
    rescue ActiveRecord::RecordNotFound
        render json: { status: 'error', message: 'Portfolio not found.' }, status: :not_found
  end


end

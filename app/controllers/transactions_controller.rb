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
    seller_portfolio = Portfolio.find(params[:portfolio_id])
    puts "Seller Portfolio: #{seller_portfolio.inspect}"
    transaction_stock_id = seller_portfolio.stock_id
    puts "Transaction Stock ID Before: #{transaction_stock_id}"
    buyer_portfolio = current_user.portfolios.find_by(stock_id: transaction_stock_id)

    if buyer_portfolio.nil?
      render json: { status: 'error', message: "Portfolio with stock_id '#{transaction_stock_id}' must exist for the current user" }, status: :unprocessable_entity
      return
    end

    quantity = params[:quantity]
    stock_price = fetch_stock_price_from_api(transaction_stock_id)

    price = stock_price[:usd]
    amount = quantity.to_f * price.to_f
    
    if quantity.to_f > seller_portfolio.quantity
      render json: { status: 'error', message: 'Insufficient portfolio quantity for the transaction' }, status: :unprocessable_entity
      return
    end

    transaction = Transaction.new(
      buyer_portfolio_id: buyer_portfolio,
      seller_portfolio_id: seller_portfolio,
      amount: amount,
      price: price,
      quantity: quantity,
      status: 'pending',
      stock_id: transaction_stock_id
    )

    if transaction.save
      render json: { status: 'success', data: transaction }, status: :created
    else
      render json: { status: 'error', errors: transaction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def approve_transaction
    begin
      portfolio = current_user.portfolios.find(params[:portfolio_id])
      transaction = portfolio.seller_transactions.find(params[:id])

      if transaction.status == 'approved'
        render json: { status: 'error', message: 'Transaction is already approved' }, status: :unprocessable_entity
        return
      end

      buyer_portfolio = transaction.buyer_portfolio

      if transaction.update(status: 'approved')
        updated_seller_quantity = portfolio.quantity - transaction.quantity
        updated_buyer_quantity = buyer_portfolio.quantity + transaction.quantity


        stock_price = fetch_stock_price_from_api(transaction.stock_id)
        updated_price = stock_price[:usd]

        updated_seller_amount = updated_seller_quantity.to_f * updated_price.to_f
        updated_buyer_amount = updated_buyer_quantity.to_f * updated_price.to_f
        
        portfolio.update(quantity: updated_seller_quantity, price: updated_price, total_amount: updated_seller_amount)
        
        buyer_portfolio.update(quantity: updated_buyer_quantity, price: updated_price, total_amount: updated_buyer_amount)

        render json: { status: 'success', message: 'Transaction approved successfully', seller: portfolio, buyer: buyer_portfolio }, status: :ok
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

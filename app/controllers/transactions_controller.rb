class TransactionsController < ApplicationController


    def index
        portfolio = Portfolio.find(params[:portfolio_id])
        buyer_transactions = portfolio.buyer_transactions
        seller_transactions = portfolio.seller_transactions

        render json: { status: 'success', buyer_transactions: buyer_transactions, seller_transactions: seller_transactions }, status: :ok
    end

    def create
    seller_portfolio = Portfolio.find(params[:portfolio_id])
    puts "Seller Portfolio: #{seller_portfolio.inspect}"
    transaction_stock_id = seller_portfolio.stock_id
    puts "Transaction Stock ID Before: #{transaction_stock_id}"
    buyer_portfolio = current_user.portfolios.find_by(stock_id: transaction_stock_id)

    quantity = params[:quantity]
    stock_price = fetch_stock_price_from_api(transaction_stock_id)

    price = stock_price[:usd]
    amount = quantity * price

    transaction = Transaction.new(
      buyer_portfolio: buyer_portfolio,
      seller_portfolio: seller_portfolio,
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

  private

  def fetch_stock_price_from_api(stock_id)
    response = RestClient.get "https://api.coingecko.com/api/v3/coins/#{stock_id}?tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false"
    json_response = JSON.parse(response.body)

    stock_price = {
      usd: json_response['market_data']['current_price']['usd']
    }

    return stock_price
  end
end

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'GET /index' do
    let(:user) { create(:user) }
    let(:portfolio) { create(:portfolio, user: user) }
    let(:user2) { create(:user) }
    let(:portfolio2) { create(:portfolio, user: user2) }

    it 'returns a list of buyer and seller transactions of user portfolio' do
      request.headers.merge!(user.create_new_auth_token)
      transaction = create(:transaction, buyer_portfolio_id: portfolio.id, seller_portfolio_id: portfolio2.id)

      request.headers.merge!(user2.create_new_auth_token)
      transaction2 = create(:transaction, buyer_portfolio_id: portfolio2.id, seller_portfolio_id: portfolio.id)

      request.headers.merge!(user.create_new_auth_token)
      get :index, params: { portfolio_id: portfolio.id }

      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('success')
      expect(response_json['buyer_transactions'].first['id']).to eq(transaction.id)
      expect(response_json['buyer_transactions'].first['buyer_portfolio_id']).to eq(portfolio.id)
      expect(response_json['buyer_transactions'].first['seller_portfolio_id']).to eq(portfolio2.id)
      expect(response_json['seller_transactions'].first['buyer_portfolio_id']).to eq(portfolio2.id)
      expect(response_json['seller_transactions'].first['seller_portfolio_id']).to eq(portfolio.id)
    end
  end

  describe 'GET /show' do
    let(:user) { create(:user) }
    let(:portfolio) { create(:portfolio, user: user) }
    let(:user2) { create(:user) }
    let(:portfolio2) { create(:portfolio, user: user2) }
    it 'returns the transaction selected' do
      request.headers.merge!(user.create_new_auth_token)
      transaction = create(:transaction, buyer_portfolio_id: portfolio.id, seller_portfolio_id: portfolio2.id)

      get :show, params: { portfolio_id: portfolio.id, id: transaction.id}

      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)
      response_data = response_json['data']
      expect(response_data['id']).to eq(transaction.id)
    end
  end

  describe 'POST /create' do
    let(:user) { create(:user) }

    let(:user2) { create(:user) }

    let(:stock_id) { 'mock_id' }
    let(:stock_price) { 100.0 }
    let(:quantity) { 10 }

    before do
      allow(controller).to receive(:fetch_stock_price_from_api).and_return({ usd: stock_price })
    end

    it 'creates a new transaction' do
      request.headers.merge!(user2.create_new_auth_token)
      seller_portfolio = create(:portfolio, user: user2, stock_id: stock_id)
      
      request.headers.merge!(user.create_new_auth_token)
      buyer_portfolio = create(:portfolio, user: user, stock_id: stock_id)

      post :create, params: { portfolio_id: seller_portfolio.id, 
      quantity: quantity
    }

    expect(response).to have_http_status(:created)
    response_json = JSON.parse(response.body)
    expect(response_json['status']).to eq('success')
    response_data = response_json['data']
    expect(response_data['status']).to eq('pending')
    expect(response_data['amount']).to eq(1000.to_d.to_s)
    expect(response_data['buyer_portfolio_id']).to eq(user.id)
    expect(response_data['seller_portfolio_id']).to eq(user2.id)
    end
  end

  describe 'PATCH /approve_transaction' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:stock_id) { 'mock_id' }
    let(:stock_price) { 100.0 }
    let(:quantity) { 10 }

    before do
      allow(controller).to receive(:fetch_stock_price_from_api).and_return({ usd: stock_price })
    end
    it 'approves a transaction' do
      # Create the portfolios associated with the respective users
      request.headers.merge!(user2.create_new_auth_token)
      seller_portfolio = create(:portfolio, user: user2, stock_id: stock_id)

      request.headers.merge!(user.create_new_auth_token)
      buyer_portfolio = create(:portfolio, user: user, stock_id: stock_id)

      # Create a pending transaction between the portfolios
      request.headers.merge!(user.create_new_auth_token)
      transaction = create(:transaction,
        buyer_portfolio: buyer_portfolio,
        seller_portfolio: seller_portfolio,
        quantity: quantity,
        status: 'pending',
        stock_id: stock_id
      )

      request.headers.merge!(user2.create_new_auth_token)
      put :approve_transaction, params: { portfolio_id: seller_portfolio.id, id: transaction.id }

      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)

      expect(response_json['status']).to eq('success')
      expect(response_json['message']).to eq('Transaction approved successfully')

      # Check that the transaction's status has been updated to 'approved'
      transaction.reload
      expect(transaction.status).to eq('approved')

      # Check that the portfolio and buyer_portfolio have been updated
      seller_portfolio.reload
      buyer_portfolio.reload
      expect(seller_portfolio.quantity).to eq(100000 - transaction.quantity)
      expect(buyer_portfolio.quantity).to eq(100000 + transaction.quantity)
    end
  end
end

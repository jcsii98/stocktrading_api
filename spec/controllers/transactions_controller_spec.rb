require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do

  let(:user) { create(:user, account_pending: false) }
  
  let(:auth_headers) { user.create_new_auth_token }
  let(:user2) { create(:user, account_pending: false) }

  let(:auth_headers_2) { user2.create_new_auth_token }
  

  describe 'GET /index' do
    it 'returns a list of buyer and seller transactions of user portfolio' do
      request.headers.merge!(user.create_new_auth_token)
      stock = create(:stock, symbol: 'aaave')
      portfolio1 = create(:portfolio, user: user, stock: stock) 
      

      request.headers.merge!(user2.create_new_auth_token)
      portfolio2 = create(:portfolio, user: user2, stock: stock) 

      request.headers.merge!(user.create_new_auth_token)
      transaction = create(:transaction, buyer_portfolio: portfolio1, seller_portfolio: portfolio2)

      request.headers.merge!(user2.create_new_auth_token)
      transaction2 = create(:transaction, buyer_portfolio: portfolio2, seller_portfolio: portfolio1)

      request.headers.merge!(user.create_new_auth_token)
      get :index, params: { portfolio_id: portfolio1.id }

      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('success')
      expect(response_json['buyer_transactions'].first['id']).to eq(transaction.id)
      expect(response_json['buyer_transactions'].first['buyer_portfolio_id']).to eq(portfolio1.id)
      expect(response_json['buyer_transactions'].first['seller_portfolio_id']).to eq(portfolio2.id)
      expect(response_json['seller_transactions'].first['buyer_portfolio_id']).to eq(portfolio2.id)
      expect(response_json['seller_transactions'].first['seller_portfolio_id']).to eq(portfolio1.id)
    end
  end

  describe 'GET /show' do
    let(:user) { create(:user) }
    let(:stock) { create(:stock, symbol: 'aaave')}
    let(:portfolio) { create(:portfolio, user: user, stock: stock) }
    let(:user2) { create(:user) }
    let(:portfolio2) { create(:portfolio, user: user2, stock: stock) }
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

  describe 'POST #create' do
    let(:stock) { create(:stock, symbol: 'aaave' )}
    let(:user) { create(:user) }
    let(:portfolio) { create(:portfolio, user: user, stock: stock) }
    let(:user2) { create(:user) }
    let(:portfolio2) { create(:portfolio, user: user2, stock: stock) }

    context 'with valid parameters' do
      let(:transaction_data) do
        {
          success: true,
          seller_portfolio: portfolio2,
          buyer_portfolio: portfolio,
          transaction_stock_id: 'stock_id',
          stock_price: 100,
          amount: 800
        }
      end

      before do
        allow(Transaction).to receive(:check_valid_entry).and_return(transaction_data)
      end

      it 'creates a new transaction' do
        request.headers.merge!(user.create_new_auth_token)
        post :create, params: { portfolio_id: portfolio.id, quantity: '800' }

        expect(response).to have_http_status(:created)
        expect(Transaction.count).to eq(1)
        response_json = JSON.parse(response.body)
        expect(response_json['status']).to eq('success')
        expect(response_json['data']['buyer_portfolio_id']).to eq(portfolio.id)
        expect(response_json['data']['seller_portfolio_id']).to eq(transaction_data[:seller_portfolio].id)
      end
    end

    context 'with invalid parameters' do
      let(:error_message) { 'Invalid transaction data' }
      let(:transaction_data) { { success: false, message: error_message } }

      before do
        allow(Transaction).to receive(:check_valid_entry).and_return(transaction_data)
      end

      it 'returns an error response' do
        request.headers.merge!(user.create_new_auth_token)
        post :create, params: { portfolio_id: portfolio.id, quantity: '800' }

        expect(response).to have_http_status(:unprocessable_entity)
        response_json = JSON.parse(response.body)
        expect(response_json['status']).to eq('error')
        expect(response_json['message']).to eq(error_message)
      end
    end
  end

  describe 'PATCH #update' do
    let(:stock) { create(:stock, symbol: 'aaave' )}
    let(:user) { create(:user) }
    let(:portfolio) { create(:portfolio, user: user, stock: stock) }
    let(:user2) { create(:user) }
    let(:portfolio2) { create(:portfolio, user: user2, stock: stock) }
    let(:transaction) { create(:transaction, amount: 100, seller_portfolio: portfolio, buyer_portfolio: portfolio2) }
    let(:transaction2) { create(:transaction, status: 'approved', amount: 100, seller_portfolio: portfolio, buyer_portfolio: portfolio2) }
    
    context 'when the user is authenticated' do
      context 'when the transaction is not approved' do
        it 'updates the transaction status to approved' do
          request.headers.merge!(user.create_new_auth_token)
          patch :update, params: { portfolio_id: portfolio.id, id: transaction.id }
          transaction.reload

          expect(transaction.status).to eq('approved')
          expect(response).to have_http_status(:ok)
        end
      end
      context 'when the transaction is already approved' do
        it 'returns an error response' do
          request.headers.merge!(user.create_new_auth_token)
          patch :update, params: { portfolio_id: portfolio.id, id: transaction2.id }
          transaction.reload

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ 'status' => 'error', 'message' => 'Transaction is already approved' })
        end
      end
    end
    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        patch :update, params: { portfolio_id: portfolio.id, id: transaction.id }

        expect(response).to have_http_status(:unauthorized)
      end
    end
    context 'when the transaction or portfolio is not found' do
      it 'returns a not found response' do
        invalid_transaction_id = transaction.id + 1
        request.headers.merge!(user.create_new_auth_token)
        patch :update, params: { portfolio_id: portfolio.id, id: invalid_transaction_id }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ 'status' => 'error', 'message' => 'Transaction not found or unauthorized' })
      end
    end
  end
end
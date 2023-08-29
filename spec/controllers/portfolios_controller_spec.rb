require 'rails_helper'

RSpec.describe PortfoliosController, type: :controller do
  let(:user) { create(:user, account_pending: false) }
  let(:stock) { create(:stock, symbol: 'aaave') }
  let(:auth_headers) { user.create_new_auth_token }

    describe 'GET #index' do
        it 'returns portfolios of current_user' do
            request.headers.merge!(auth_headers)
            
            stock = create(:stock, symbol: 'aaave')  
            portfolio1 = create(:portfolio, user: user, stock: stock)  

            get :index

            expect(response).to have_http_status(:success)

            response_json = JSON.parse(response.body)
            response_data = response_json['data']
            expect(response_data).to include(
            a_hash_including('id' => portfolio1.id, 'stock_id' => stock.id)  
            )
        end

        it 'returns an empty array when no portfolios are found' do
            request.headers.merge!(auth_headers)

            get :index

            expect(response).to have_http_status(:success)

            response_json = JSON.parse(response.body)
            expect(response_json['message']).to eq('No portfolios found for current_user')
        end
    end


  describe 'POST #create' do
    it 'creates a new portfolio' do
      request.headers.merge!(auth_headers)


      post :create, params: { portfolio: { user: user, stock: stock, stock_symbol: 'aaave', quantity: 100 } }

      expect(response).to have_http_status(:created)

      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('success')
      expect(response_json['data']['id']).to eq(stock.id)
    end

    it 'returns an error when creating a portfolio with invalid stock symbol' do
      request.headers.merge!(auth_headers)

      post :create, params: { portfolio: { user: user, stock: stock, stock_symbol: 'invalid-stock-symbol', quantity: 100 } }

      expect(response).to have_http_status(:unprocessable_entity)

      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('error')
      expect(response_json['errors']).to include("Invalid symbol")
    end
  end

  describe 'GET #show' do
    it 'returns the details of a portfolio' do
      request.headers.merge!(auth_headers)
      portfolio = create(:portfolio, user: user, stock: stock)

      get :show, params: { id: portfolio.id }

      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('success')
      expect(response_json['data']['id']).to eq(portfolio.id)
    end

    it 'returns an error when portfolio is not found' do
      request.headers.merge!(auth_headers)

      get :show, params: { id: 999 }

      expect(response).to have_http_status(:not_found)
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).to eq('Portfolio not found')
    end
  end

  describe 'PATCH #update' do
    it 'updates portfolio quantity and amount' do
      request.headers.merge!(auth_headers)
      old_quantity = 100
      new_quantity = 200
      portfolio = create(:portfolio, user: user, stock: stock, quantity: old_quantity)
      
      patch :update, params: { id: portfolio.id, portfolio: { stock_symbol: stock.symbol, quantity: new_quantity } }


      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('success')
      expect(response_json['data']['id']).to eq(portfolio.id)
      expect(response_json['data']['quantity']).to eq(new_quantity.to_d.to_s)
      expect(response_json['data']['total_amount']).to eq(new_quantity.to_d.to_s)
    end

    it 'returns an error when portfolio is not found' do
      request.headers.merge!(auth_headers)

      get :show, params: { id: 999 }

      expect(response).to have_http_status(:not_found)
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).to eq('Portfolio not found')
    end
  end
end

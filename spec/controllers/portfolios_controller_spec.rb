require 'rails_helper'

RSpec.describe PortfoliosController, type: :controller do
    let(:user) { create(:user, account_pending: false) }
    let(:auth_headers) { user.create_new_auth_token }
    let(:user2) { create(:user, account_pending: false) } 
    let(:auth_headers_2) { user2.create_new_auth_token }

    before do
        request.headers.merge!(auth_headers)
        stocks_service = MockStocksService.new
        allow(StocksService).to receive(:new).and_return(stocks_service)
    end

    describe 'GET #index' do
        it 'returns a successful response' do
            get :index
            expect(response).to have_http_status(:success)
        end
        it 'returns portfolios of current_user' do
            request.headers.merge!(auth_headers)
            portfolio1 = create(:portfolio, user: user)
            get :index
            expect(response).to have_http_status(:success)

            response_json = JSON.parse(response.body)
            response_data = response_json['data']
            expect(response_data).to include(
            a_hash_including('id' => portfolio1.id, 'stock_id' => portfolio1.stock_id)
            )
        end
        it 'returns an empty array when no portfolios are found' do
            get :index
            
            expect(response).to have_http_status(:success)
            response_json = JSON.parse(response.body)

            expect(response_json['message']).to eq('No portfolios found for current_user')
        end
    end

    describe 'POST #create' do
        let(:valid_stock_id) { 'valid_stock_id' }
        let(:invalid_stock_id) { 'invalid_stock_id' }
        let(:valid_stock_price) { 10.to_d.to_s }
        let(:portfolio_params) { { stock_id: valid_stock_id, quantity: 1 } }


        context 'with valid parameters' do

            it 'creates a portfolio' do
                post :create, params: { portfolio: portfolio_params }

                expect(response).to have_http_status(:created)
                response_json = JSON.parse(response.body)
                expect(response_json['status']).to eq('success')
                expect(response_json['data']['stock_id']).to eq(valid_stock_id)
                expect(response_json['data']['price']).to eq(valid_stock_price)
                expect(response_json['data']['quantity']).to eq(1.to_d.to_s)
            end
        end

        context 'with invalid parameters' do

            it 'returns an error when stock_id is invalid' do
                post :create, params: { portfolio: { stock_id: invalid_stock_id, quantity: 1 } }

                expect(response).to have_http_status(:unprocessable_entity)
                response_json = JSON.parse(response.body)
                expect(response_json['status']).to eq('error')
                expect(response_json['message']).to eq('Invalid stock_id')
            end
            it 'returns an error when quantity is negative' do

                post :create, params: { portfolio: { stock_id: valid_stock_id, quantity: -1 } }

                expect(response).to have_http_status(:unprocessable_entity)
                response_json = JSON.parse(response.body)
                expect(response_json['status']).to eq('error')
                expect(response_json['errors']).to include('Quantity must be a positive number')
            end
        end
    end

    describe 'GET /show' do
            let(:valid_stock_id) { 'valid_stock_id' }
            let(:valid_stock_price) { 10.to_d.to_s }
            let(:portfolio_params) { { stock_id: valid_stock_id, quantity: 1 } }

        it 'returns the portfolio chosen' do

            post :create, params: { portfolio: portfolio_params }

            get :show, params: { id: 1 }
            expect(response).to have_http_status(:ok)
            response_json = JSON.parse(response.body)
            response_data = response_json['data']
            expect(response_data['id']).to eq(1)
        end

        it 'returns an error when portfolio does not exist' do
            get :show, params: { id: 1 }
            expect(response).to have_http_status(:not_found)
        end
    end

    describe 'PATCH /update' do
        let(:portfolio) { create(:portfolio, user: user, quantity: 0, price: 10) }

        it 'updates quantity and total_amount' do
            new_quantity = 10.to_d.to_s
            patch :update, params: { id: portfolio.id, portfolio: { quantity: new_quantity } }

            expect(response).to have_http_status(:success)
            response_json = JSON.parse(response.body)
            expect(response_json['status']).to eq('success')
            response_data = response_json['data']
            expect(response_data['quantity']).to eq(new_quantity)
            expect(response_data['total_amount']).to eq(100.to_d.to_s)
        end
    end

    describe 'DELETE /destroy' do
        let(:portfolio) { create(:portfolio, user: user, quantity: 0, price: 10) }
        it 'deletes a portfolio' do
            delete :destroy, params: { id: portfolio.id }

            expect(response).to have_http_status(:success)
            response_json = JSON.parse(response.body)

            expect(response_json['status']).to eq('success')
            expect(response_json['message']).to eq('Portfolio successfully deleted')
        end
    end
end

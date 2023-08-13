require 'rails_helper'

RSpec.describe PortfoliosController, type: :controller do
    let(:user) { create(:user, account_pending: false) }
    let(:auth_headers) { user.create_new_auth_token }

    let(:user2) { create(:user, account_pending: false) } 
    let(:auth_headers_2) { user2.create_new_auth_token }

    before do
        request.headers.merge!(auth_headers)
    end

    describe 'GET #index' do
        it 'returns a successful response' do
            get :index
            expect(response).to have_http_status(:success)
        end
        it 'returns portfolios of current_user' do
            # Stub API calls
            allow(controller).to receive(:verify_available_stock).and_return([
                { id: 'valid_stock_id' },
                { id: 'valid_stock_id_2' },
                { id: 'valid_stock_id_3' }
            ])
            allow(controller).to receive(:fetch_price_from_api).and_return(10) 

            # Create a portfolio with a valid stock_id
            post :create, params: { portfolio: { stock_id: 'valid_stock_id', quantity: 1 } }
            post :create, params: { portfolio: { stock_id: 'valid_stock_id_2', quantity: 1 } }
            post :create, params: { portfolio: { stock_id: 'valid_stock_id_3', quantity: 1 } }
            
            created_portfolio_ids = []
            Portfolio.where(user_id: user.id).each do |portfolio|
                created_portfolio_ids << portfolio.id
            end

            get :index
            expect(response).to have_http_status(:success)

            response_json = JSON.parse(response.body)
            response_data = response_json['data']
            response_ids = response_data.pluck('id')


            # Check if the IDs in the response match the ID of the portfolio you created
            expect(response_ids).to match_array(created_portfolio_ids)
        end
        it 'returns an empty array when no portfolios are found' do
            get :index
            
            expect(response).to have_http_status(:success)
            response_json = JSON.parse(response.body)

            expect(response_json['message']).to eq('No portfolios found for current_user')
        end
    end

    describe 'GET #index_by_stock' do
        it 'returns portfolios of a certain stock_id' do
            allow(controller).to receive(:verify_available_stock).and_return([{ id: 'valid_stock_id' }])
            allow(controller).to receive(:fetch_price_from_api).and_return(10)

            # create portfolio for user1
            post :create, params: { portfolio: { stock_id: 'valid_stock_id', quantity: 1 } }
            # create portfolio for user2
            request.headers.merge!(auth_headers_2)
            post :create, params: { portfolio: { stock_id: 'valid_stock_id', quantity: 1 } }
            
            get :index_by_stock, params: { stock_id: 'valid_stock_id' }
            expect(response).to have_http_status(:success)

            response_json = JSON.parse(response.body)
            response_data = response_json['data']
            response_ids = response_data.pluck('id')

            created_portfolio_user1 = Portfolio.find_by(stock_id: 'valid_stock_id', user_id: user.id)
            created_portfolio_user2 = Portfolio.find_by(stock_id: 'valid_stock_id', user_id: user2.id)

            expect(response_ids).to include(created_portfolio_user1.id, created_portfolio_user2.id)
        end
        
        it 'returns error when stock_id does not exist' do
            allow(controller).to receive(:verify_available_stock).and_return([{ id: 'valid_stock_id' }])
            allow(controller).to receive(:fetch_price_from_api).and_return(10)

            # create portfolio for user1
            post :create, params: { portfolio: { stock_id: 'valid_stock_id', quantity: 1 } }
            # create portfolio for user2
            request.headers.merge!(auth_headers_2)
            post :create, params: { portfolio: { stock_id: 'valid_stock_id', quantity: 1 } }

            get :index_by_stock, params: { stock_id: 'invalid_stock_id' }
            expect(response).to have_http_status(:unprocessable_entity)

            response_json = JSON.parse(response.body)

            expect(response_json['status']).to eq('error')
            expect(response_json['message']).to eq('No portfolios found for the specified stock_id') 
        end
    end

    describe 'GET #index_by_user' do
        context 'when user has portfolios and admin is signed in' do
            let(:admin) { create(:admin) }
            let(:admin_auth_headers) { admin.create_new_auth_token }
            before { request.headers.merge!(admin_auth_headers) }
            
            it 'returns portfolios of a user' do
                allow(controller).to receive(:verify_available_stock).and_return([
                    { id: 'valid_stock_id' },
                    { id: 'valid_stock_id_2' }
                ])
                allow(controller).to receive(:fetch_price_from_api).and_return(10)

                # create portfolio for user1
                request.headers.merge!(auth_headers)
                post :create, params: { portfolio: { stock_id: 'valid_stock_id', quantity: 1 } }
                post :create, params: { portfolio: { stock_id: 'valid_stock_id_2', quantity: 1 } }
                user1_created_portfolio_ids = []
                Portfolio.where(user_id: user.id).each do |portfolio|
                    user1_created_portfolio_ids << portfolio.id
                end
                
                # create portfolio for user2
                request.headers.merge!(auth_headers_2)
                post :create, params: { portfolio: { stock_id: 'valid_stock_id', quantity: 1 } }
                post :create, params: { portfolio: { stock_id: 'valid_stock_id_2', quantity: 1 } }

                request.headers.merge!(admin_auth_headers)
                get :index_by_user, params: { user_id: 1 }
                expect(response).to have_http_status(200)

                response_json = JSON.parse(response.body)
                response_data = response_json['data']
                response_ids = response_data.map { |portfolio| portfolio['id'] }
                expect(response_ids).to match_array(user1_created_portfolio_ids)
            end
        end
        it 'returns error if accessed by non-admin' do
            get :index_by_user, params: { user_id: 1}

            expect(response).to have_http_status(:unauthorized)
            response_json = JSON.parse(response.body)
            expect(response_json['errors']).to include('You need to sign in or sign up before continuing.')
        end
    end

    describe 'POST #create' do
        let(:valid_stock_id) { 'valid_stock_id' }
        let(:invalid_stock_id) { 'invalid_stock_id' }
        let(:valid_stock_price) { 10.to_d.to_s }
        let(:portfolio_params) { { stock_id: valid_stock_id, quantity: 1 } }

        before do
            allow(controller).to receive(:fetch_price_from_api).with(valid_stock_id).and_return(valid_stock_price)
        end

        context 'with valid parameters' do
            before do
                allow(controller).to receive(:verify_available_stock).with(valid_stock_id).and_return([{ id: valid_stock_id }])
            end

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
                allow(controller).to receive(:verify_available_stock).with(invalid_stock_id).and_return([])
                post :create, params: { portfolio: { stock_id: invalid_stock_id, quantity: 1 } }

                expect(response).to have_http_status(:unprocessable_entity)
                response_json = JSON.parse(response.body)
                expect(response_json['status']).to eq('error')
                expect(response_json['message']).to eq('Invalid stock_id')
            end
            it 'returns an error when quantity is negative' do
                allow(controller).to receive(:verify_available_stock).with(valid_stock_id).and_return([{ id: valid_stock_id }])

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
            allow(controller).to receive(:fetch_price_from_api).with(valid_stock_id).and_return(valid_stock_price)
            allow(controller).to receive(:verify_available_stock).with(valid_stock_id).and_return([{ id: valid_stock_id }])

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

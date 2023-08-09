require 'rails_helper'

RSpec.describe TestController, type: :controller do
  describe 'GET #users_only' do
    context 'when user is authenticated' do
      it 'returns a success response' do
        user = create(:user)  # Assuming you have a User factory set up
        
        # Generate and set an authentication token for the user
        auth_headers = user.create_new_auth_token
        
        request.headers.merge!(auth_headers)  # Set authentication headers
        
        get :users_only

        expect(response).to have_http_status(:success)
        
        response_json = JSON.parse(response.body)
        
        expect(response_json['data']['message']).to eq("Welcome #{user.full_name}")
        expect(response_json['data']['user']['id']).to eq(user.id)
      end
    end

    context 'when user is not authenticated' do
      it 'returns an unauthorized response' do
        get :users_only

        expect(response).to have_http_status(:unauthorized)
        
        response_json = JSON.parse(response.body)
        
        expect(response_json['errors']).to include('You need to sign in or sign up before continuing.')
      end
    end
  end
  describe 'GET #admins_only' do
    context 'when admin is authenticated' do
      it 'returns a success response' do
        admin = create(:admin)  # Assuming you have a User factory set up
        
        # Generate and set an authentication token for the user
        auth_headers = admin.create_new_auth_token
        
        request.headers.merge!(auth_headers)  # Set authentication headers
        
        get :admins_only

        expect(response).to have_http_status(:success)
        
        response_json = JSON.parse(response.body)
        
        expect(response_json['data']['message']).to eq("Welcome #{admin.full_name}")
        expect(response_json['data']['user']['id']).to eq(admin.id)
      end
    end

    context 'when admin is not authenticated' do
      it 'returns an unauthorized response' do

        # simulate user login
        user = create(:user)
        auth_headers = user.create_new_auth_token
        request.headers.merge!(auth_headers)

        get :admins_only

        expect(response).to have_http_status(:unauthorized)
        
        response_json = JSON.parse(response.body)
        
        expect(response_json['errors']).to include('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'GET #approved_users_only' do
    context 'when user is not authenticated' do
      it 'returns unauthorized' do

        get :approved_users_only

        expect(response).to have_http_status(:unauthorized)

        response_json = JSON.parse(response.body)

        expect(response_json['errors']).to include('You need to sign in or sign up before continuing.')
      end
    end

    context 'when user is authenticated only' do
      it 'returns user is pending approval' do
        user = create(:user)
        auth_headers = user.create_new_auth_token
        request.headers.merge!(auth_headers)

        get :approved_users_only

        expect(response).to have_http_status(:unprocessable_entity)

        response_json = JSON.parse(response.body)

        expect(response_json['data']['message']).to eq("User is pending approval")
      end
    end
    
    context 'when user is authenticated and approved' do
      it 'returns welcome' do
      user = create(:user, account_pending: false)
      auth_headers = user.create_new_auth_token
      request.headers.merge!(auth_headers)

      get :approved_users_only
      
      expect(response).to have_http_status(200)

      response_json = JSON.parse(response.body)

      expect(response_json['data']['message']).to eq("Welcome #{user.full_name}")
      end
    end

  end

end

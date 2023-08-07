require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /auth' do
    let(:valid_user_attributes) do
        attributes_for(:user,
        full_name: 'Jose Saribong',
        user_name: 'josesaribong',
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
    )
    end

    it 'registers a new user' do
      post '/auth', params: { user:  valid_user_attributes }
      
      
      expect(response).to have_http_status(:success)
      
      response_json = JSON.parse(response.body)
      
      expect(response_json).to include('status' => 'success')
      expect(response_json['data']).to include('uid' => 'test@example.com')
    end

    it 'returns an error if password confirmation does not match' do
      post '/auth', params: { user: valid_user_attributes.merge(password_confirmation: '123password') }
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      response_json = JSON.parse(response.body)
      
      expect(response_json).to include('status' => 'error', 'errors' => 'Password and password confirmation do not match')
    end

    it 'returns an error if email is already in use' do
        user1 = post '/auth', params: { user: valid_user_attributes.merge(email: 'test@email.com') }
        user2 = post '/auth', params: { user: valid_user_attributes.merge(email: 'test@email.com') }

        expect(response).to have_http_status(:unprocessable_entity)
        response_json = JSON.parse(response.body)

        expect(response_json).to include('status'=>'error')
        expect(response_json['errors']).to include('Email has already been taken')
    end
  end

  describe 'POST /admin_auth' do
    let(:valid_admin_attributes) do
        attributes_for(:admin,
        full_name: 'Jose Saribong',
        user_name: 'josesaribong',
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
    )
    end

    it 'registers a new admin' do
      post '/admin_auth', params: { admin:  valid_admin_attributes }
      
      
      expect(response).to have_http_status(:success)
      
      response_json = JSON.parse(response.body)
      
      expect(response_json).to include('status' => 'success')
      expect(response_json['data']).to include('uid' => 'test@example.com')
    end

    it 'returns an error if password confirmation does not match' do
      post '/admin_auth', params: { admin: valid_admin_attributes.merge(password_confirmation: '123password') }
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      response_json = JSON.parse(response.body)
      
      expect(response_json).to include('status' => 'error', 'errors' => 'Password and password confirmation do not match')
    end

    it 'returns an error if email is already in use' do
        admin1 = post '/admin_auth', params: { admin: valid_admin_attributes.merge(email: 'test@email.com') }
        admin2 = post '/admin_auth', params: { admin: valid_admin_attributes.merge(email: 'test@email.com') }

        expect(response).to have_http_status(:unprocessable_entity)
        response_json = JSON.parse(response.body)

        expect(response_json).to include('status'=>'error')
        expect(response_json['errors']).to include('Email has already been taken')
    end
  end

end

require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /auth' do

    it 'registers a new user and sends a confirmation email' do
      user_params = attributes_for(:user)

      post '/auth', params: user_params
      
      expect(response).to have_http_status(:success)
      
      response_json = JSON.parse(response.body)
      
      expect(response_json).to include('status' => 'success')
      expect(response_json['data']).to include('uid' => user_params[:email])

      confirmation_email = Devise::Mailer.deliveries.last
      expect(confirmation_email).not_to be_nil
      expect(confirmation_email.subject).to eq('Email Confirmation')
    end

    it 'returns an error if password confirmation does not match' do

      user_params = attributes_for(:user)

      post '/auth', params: user_params.merge(password: 'password123', password_confirmation: '123password')
      
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('error')
      expect(response_json['errors']['password_confirmation']).to include("doesn't match Password")
    end

    it 'returns an error if email is already in use' do
      existing_user = FactoryBot.create(:user, email: 'test@example.com')

      user_params = {
        full_name: 'Jose Saribong',
        user_name: 'josesaribong',
        email: existing_user.email,
        password: 'password123',
        password_confirmation: 'password123'
      }

      post '/auth', params: user_params
      
      expect(response).to have_http_status(:unprocessable_entity)
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('error')
      expect(response_json['errors']['email']).to include('has already been taken')
    end
  end

  describe 'POST /admin_auth' do

    it 'registers a new admin' do

      admin_params = attributes_for(:admin)

      post '/admin_auth', params: admin_params
      
      
      expect(response).to have_http_status(:success)
      
      response_json = JSON.parse(response.body)
      
      expect(response_json).to include('status' => 'success')
      expect(response_json['data']).to include('uid' => admin_params[:email])
    end

    it 'returns an error if password confirmation does not match' do
      admin_params = attributes_for(:admin)

      post '/admin_auth', params: admin_params.merge(password: '123password', password_confirmation: 'password123')
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      response_json = JSON.parse(response.body)
      
      expect(response_json['status']).to eq('error')
      expect(response_json['errors']['password_confirmation']).to include("doesn't match Password")
    end

    it 'returns an error if email is already in use' do
      existing_admin = FactoryBot.create(:admin, email: 'test@example.com')

      admin_params = {
        full_name: 'Jose Saribong',
        user_name: 'josesaribong',
        email: existing_admin.email,
        password: 'password123',
        password_confirmation: 'password123'
      }

      post '/admin_auth', params: admin_params
      
      expect(response).to have_http_status(:unprocessable_entity)
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('error')
      expect(response_json['errors']['email']).to include('has already been taken')
    end
  end

end

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'GET /index' do
    let(:user) { create(:user) }
    let(:portfolio) { create(:portfolio, user: user) }
    let(:user2) { create(:user) }
    let(:portfolio2) { create(:portfolio, user: user2) }

    before do
      request.headers.merge!(user.create_new_auth_token)
    end

    it 'returns a list of buyer and seller transactions of the user' do
      transaction = create(:transaction, buyer_portfolio_id: portfolio.id, seller_portfolio_id: portfolio2.id)

      get :index, params: { portfolio_id: portfolio.id }

      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('success')
      expect(response_json['buyer_transactions'].first['id']).to eq(transaction.id)
      expect(response_json['buyer_transactions'].first['buyer_portfolio_id']).to eq(portfolio.id)
      expect(response_json['buyer_transactions'].first['seller_portfolio_id']).to eq(portfolio2.id)
    end
  end
end

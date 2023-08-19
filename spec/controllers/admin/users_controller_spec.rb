require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin) { create(:admin) }
  let(:auth_headers) { admin.create_new_auth_token }

  describe "GET /index" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    before { request.headers.merge!(auth_headers) }

    before { get :index }

    it "returns a list of all users" do
      expect(response).to have_http_status(200)
      response_json = JSON.parse(response.body)
      expect(response_json.pluck("id")).to match_array([user1.id, user2.id])
    end
  end

  describe "GET /show" do
    context "when user exists" do
      let!(:user) { create(:user) }

      before { request.headers.merge!(auth_headers) }

      before { get :show, params: { id: user.id } }

      it "returns the user" do
        expect(response).to have_http_status(200)
        response_json = JSON.parse(response.body)
        expect(response_json["id"]).to eq(user.id)
      end
    end

    context "when user does not exist" do
      before { request.headers.merge!(auth_headers) }

      before { get :show, params: { id: 123 } }

      it "returns a not found error" do
        expect(response).to have_http_status(404)
        response_json = JSON.parse(response.body)
        expect(response_json["error"]).to eq("User not found")
      end
    end
  end

end
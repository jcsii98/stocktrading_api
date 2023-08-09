require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  describe "GET /index" do
    it "returns a list of all users" do
      user1 = create(:user)
      user2 = create(:user)

      admin = create(:admin)
      auth_headers = admin.create_new_auth_token

      get admin_users_path, headers: auth_headers

      expect(response).to have_http_status(200)

      response_json = JSON.parse(response.body)

      expect(response_json.pluck("id")).to match_array([user1.id, user2.id])
    end
  end

  describe "GET /pending_accounts" do
    it "returns a list of users that are pending" do
      user1 = create(:user)
      user2 = create(:user, account_pending: false)
      user3 = create(:user)
      
      admin = create(:admin)
      auth_headers = admin.create_new_auth_token

      get pending_accounts_admin_users_path, headers: auth_headers

      expect(response).to have_http_status(200)

      response_json = JSON.parse(response.body)

      expect(response_json.pluck("id")).to match_array([user1.id, user3.id])
    end
  end

  describe "GET /show_pending_account" do
    it "returns the pending user" do
      user1 = create(:user, full_name: "Jose Saribong")
      user2 = create(:user, full_name: "Jose Saribong II")

      admin = create(:admin)
      auth_headers = admin.create_new_auth_token

      get show_pending_account_admin_user_path(user1), headers: auth_headers

      expect(response).to have_http_status(200)

      response_json = JSON.parse(response.body)
      expect(response_json["full_name"]).to eq("Jose Saribong")
    end
  end

  describe "PATCH /update" do
    it "updates a user's account_pending status" do
      user1 = create(:user)
      user2 = create(:user)

      admin = create(:admin)
      auth_headers = admin.create_new_auth_token

      patch admin_user_path(user2), headers: auth_headers

      expect(response).to have_http_status(200)

      response_json = JSON.parse(response.body)

      expect(response_json["message"]).to eq("User approved")
      expect(response_json["user"]).to include(
        "id" => user2.id,
        "full_name" => user2.full_name,
        "email" => user2.email,
        "account_pending" => false
      )
    end
  end


end

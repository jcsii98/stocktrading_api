class TestController < ApplicationController
  before_action :authenticate_user!, only: [:users_only, :approved_users_only]
  before_action :verify_approved, only: [:approved_users_only]
  before_action :authenticate_admin!, only: [:admins_only]

  def users_only
    render json: {
      data:  current_user 
    }, status: 200
  end

  def approved_users_only
    render json: { 
      data: {
        message: "Welcome #{current_user.full_name}",
        user: current_user
      }
    }, status: 200
  end


  def admins_only
    render json: {
      data: {
        message: "Welcome #{current_admin.full_name}",
        user: current_admin
      }
    }, status: 200
  end

  private

  def verify_approved
    if current_user.account_pending
      render json: { data: { message: "User is pending approval" } }, status: :unprocessable_entity
    else
      return true
    end
  end

end
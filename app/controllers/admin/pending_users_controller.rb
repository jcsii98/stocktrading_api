class Admin::PendingUsersController < ApplicationController
  before_action :authenticate_admin!

  def index
    pending_users = UsersService.get_pending_users
    render json: pending_users
  end

  def show
    pending_user = UsersService.get_pending_user_by_id(params[:id])
    render json: pending_user
  end

  def update
    pending_user = UsersService.get_pending_user_by_id(params[:id])
    if pending_user && pending_user.account_pending
      if AccountApprovalService.approve_user_account(pending_user)
        render json: { message: "User approved", user: UsersService.response_user_attributes(pending_user) }
      else
        render json: { error: "Failed to approve user" }, status: :unprocessable_entity
      end
    else
      render json: { error: "User is not pending" }, status: :unprocessable_entity
    end
  end
end

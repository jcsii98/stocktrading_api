class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_user, only: [:show, :update]

  def index
    users = UsersService.get_all_users
    render json: users
  end

  def show
    render json: @user
  end

  private

  def set_user
    @user = UsersService.get_user_by_id(params[:id])
    render json: { error: "User not found" }, status: :not_found unless @user
  end
end

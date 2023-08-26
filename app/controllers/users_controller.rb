class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:update]
  before_action :authorize_access, only: [:show]
  def show 
    if current_admin
      admin = current_admin
      render json: admin
    else
      user = current_user
      render json: current_user
    end
    # user = current_user
    # render json: current_user
  end
  
  def update
    user = current_user
    amount = params[:amount].to_f

    if amount <= 0
      render json: { status: 'error', message: "Amount must be a positive number" }, status: :unprocessable_entity
      return
    end

    user.add_to_wallet(amount)

    render json: { status: 'success', message: "Funds added successfully. New wallet balance: #{user.wallet_balance}" }, status: :ok
  end

  private
  
  def authorize_access
    if current_admin
      authenticate_admin!
    else
      authenticate_user!
    end
  rescue
    render json: { status: 'error', message: 'You are not authorized to access this resource.' }, status: :forbidden
  end
  def user_params
    params.require(:user).permit(:wallet_balance)
  end
end

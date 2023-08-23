class UsersController < ApplicationController
  before_action :authenticate_user!

  def show 
    user = current_user
    render json: {
      wallet_balance: user.wallet_balance,
      pending_amount: user.pending_amount }
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

  def user_params
    params.require(:user).permit(:wallet_balance)
  end
end

class Admin::UsersController < ApplicationController
    before_action :authenticate_admin!
    
    def index
        users = User.all
        render json: users
    end

    def show
        user = User.find_by_id(params[:id])
        if user
            render json: user
        else
            render json: { error: "User does not exist" }, status: :not_found
        end
    end

    def pending_accounts
        pending_users = User.where(account_pending: true)
        render json: pending_users
    end

    def show_pending_account
        pending_user = User.find_by_id(params[:id])
        if pending_user
            if pending_user.account_pending
                render json: pending_user
            else
                render json: { error: "User is not pending" }, status: :unprocessable_entity
            end
        else
            render json: { error: "User not found" }, status: :not_found
        end
    end

    def update
        user = User.find(params[:id])
        if user.update(account_pending: false)
            UserMailer.account_approved(user).deliver_now
            render json: { message: "User approved", user: response_user_attributes(user) }
        else
            render json: { error: "Failed to approve user" }, status: :unprocessable_entity
        end
    end

    private

    def response_user_attributes(user)
    {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        account_pending: user.account_pending
    }
    end

end

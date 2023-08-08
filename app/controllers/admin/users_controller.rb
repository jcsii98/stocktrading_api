class Admin::UsersController < ApplicationController
    before_action :authenticate_admin!

    def index
        users = User.all
        render json: users
    end

    def update
        user = User.find(params[:id])
        if user.update(user_params)
            render json: { message: "User column updated successfully" }
        else
            render json: { error: "Failed to update user column" }, status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.require(:user).permit(:account_pending)  
    end
end

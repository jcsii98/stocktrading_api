class PortfoliosController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_approved, only: [:controlleractionhere]

    def create
        user = current_user

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

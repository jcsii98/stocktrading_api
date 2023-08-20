class AdminsController < ApplicationController
  before_action :authenticate_admin!

  def show 
    admin = current_admin
    render json: {
        data: {
            admin: admin
        }
    }
  end
  

end

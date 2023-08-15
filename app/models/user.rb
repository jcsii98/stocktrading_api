# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  include DeviseTokenAuth::Concerns::User


  

  has_many :portfolios

  def add_to_wallet(amount)
    self.wallet_balance += amount
    save
  end

  def update_wallet_balance(amount, direction)
    if amount == nil
      render json: { status: 'error', message: 'amount is nil' }
    end
    current_balance = wallet_balance
    if current_balance == nil
      render json: { status: 'error', message: 'current_balance is nil' }
    end

    
    if direction == :add
      new_balance = current_balance + amount
    elsif direction == :subtract
      new_balance = current_balance - amount
    else
      raise ArgumentError, "Invalid direction: #{direction}"
    end
    update(wallet_balance: new_balance)
    Rails.logger.debug("User's wallet balance updated to #{new_balance}")
  end

end

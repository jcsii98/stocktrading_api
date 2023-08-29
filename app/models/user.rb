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

  # on transaction.create

  def can_cover_resulting_pending_amount(amount)
    resulting_pending_amount = pending_amount + amount
    if resulting_pending_amount <= self.wallet_balance
      { success: true, message: 'User can cover resulting pending amount'}
    else
      insufficient_amount = resulting_pending_amount - self.wallet_balance
      { success: false, message: "User cannot cover resulting pending amount. Please top up: #{insufficient_amount}" }
    end
  end
  
  def add_pending_amount(amount)
    update(pending_amount: pending_amount + amount)
  end

  # on transaction.approve

  def update_wallet_balance(amount, direction)
    # check if amount is nil
    if amount == nil
      render json: { status: 'error', message: 'amount is nil' }
    end
    
    # check if user wallet_balance is nil
    if wallet_balance == nil
      render json: { status: 'error', message: 'wallet_balance is nil' }
    end
    
    before_balance = wallet_balance
    before_pending = pending_amount

    if direction == :add
      # direction :add = seller
      new_wallet_balance = before_balance + amount
      new_pending_amount = before_pending
    elsif direction == :subtract
      # direction :subtract = buyer
      new_wallet_balance = before_balance - amount
      new_pending_amount = before_pending - amount
    else
      raise ArgumentError, "Invalid direction: #{direction}"
    end
    update(wallet_balance: new_wallet_balance, pending_amount: new_pending_amount)
    Rails.logger.debug("User's wallet balance updated from #{before_balance} to #{new_wallet_balance} and pending amount has been adjusted from #{before_pending} to #{new_pending_amount}")
  end

end

class AddWalletBalanceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :wallet_balance, :decimal, default: 0.0
  end
end

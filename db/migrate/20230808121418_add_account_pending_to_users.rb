class AddAccountPendingToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :account_pending, :boolean, default: true
  end
end

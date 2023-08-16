class AddPendingAmountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :pending_amount, :decimal, default: "0.0"
  end
end

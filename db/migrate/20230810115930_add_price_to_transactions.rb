class AddPriceToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :price, :decimal, precision: 15, scale: 10
  end
end

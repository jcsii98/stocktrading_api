class AddPriceToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :price, :decimal, precision: 10, scale: 8
  end
end

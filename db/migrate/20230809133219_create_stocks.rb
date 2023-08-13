class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks do |t|
      t.string :stock_id
      t.decimal :price, precision: 15, scale: 10
      t.decimal :quantity, precision: 15, scale: 10
      t.decimal :total_amount, precision: 15, scale: 10
      t.timestamps
    end
  end
end

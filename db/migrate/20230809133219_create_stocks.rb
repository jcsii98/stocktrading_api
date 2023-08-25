class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.string :name
      t.float :usd, precision: 15, scale: 10
      t.timestamps
    end
  end
end

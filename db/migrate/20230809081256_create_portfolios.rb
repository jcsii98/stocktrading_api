class CreatePortfolios < ActiveRecord::Migration[7.0]
  def change
    create_table :portfolios do |t|
      t.string :stock_symbol
      t.references :stock, null: false, foreign_key: true
      t.decimal :quantity, precision: 15, scale: 10
      t.decimal :price, precision: 15, scale: 10
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

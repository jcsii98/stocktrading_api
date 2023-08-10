class CreatePortfolios < ActiveRecord::Migration[7.0]
  def change
    create_table :portfolios do |t|
      t.string :stock_id
      t.integer :quantity
      t.decimal :price, precision: 10, scale: 8
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

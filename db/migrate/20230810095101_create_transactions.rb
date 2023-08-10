class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.integer :buyer_portfolio_id
      t.integer :seller_portfolio_id
      t.string :stock_id
      t.decimal :quantity
      t.decimal :amount
      t.string :status

      t.timestamps
    end

    add_foreign_key :transactions, :portfolios, column: :buyer_portfolio_id
    add_foreign_key :transactions, :portfolios, column: :seller_portfolio_id
  end
end

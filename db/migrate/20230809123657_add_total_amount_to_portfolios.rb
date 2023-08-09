class AddTotalAmountToPortfolios < ActiveRecord::Migration[7.0]
  def change
    add_column :portfolios, :total_amount, :decimal, precision: 10, scale: 2, null: false
  end
end

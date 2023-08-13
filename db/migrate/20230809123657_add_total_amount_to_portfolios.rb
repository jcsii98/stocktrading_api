class AddTotalAmountToPortfolios < ActiveRecord::Migration[7.0]
  def change
    add_column :portfolios, :total_amount, :decimal, default: 0.0, precision: 15, scale: 10, null: false
  end
end

class AddDefaultTotalAmountToPortfolios < ActiveRecord::Migration[7.0]
  def change
    change_column :portfolios, :total_amount, :decimal, default: 0.0, precision: 10, scale: 2
  end
end

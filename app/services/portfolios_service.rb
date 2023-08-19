class PortfoliosService
  def self.index_by_stock_id(stock_id)
    Portfolio.where(stock_id: stock_id)
  end

  def self.index_by_user(user_id)
    Portfolio.where(user_id: user_id)
  end
end
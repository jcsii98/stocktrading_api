class PortfoliosService
  def self.index_by_stock_id(stock_id)
    portfolios = Portfolio.where(stock_id: stock_id)
    portfolios
  end

  def self.index_by_user(user_id)
    portfolios = Portfolio.where(user_id: user_id)
    portfolios
  end
end
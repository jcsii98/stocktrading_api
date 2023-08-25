class PortfoliosService
  def self.index_by_stock_symbol(stock_symbol)
    portfolios = Portfolio.where(stock_symbol: stock_symbol)
    portfolios
  end

  def self.index_by_user(user_id)
    portfolios = Portfolio.where(user_id: user_id)
    portfolios
  end
end
class PortfolioCreator
    attr_reader :portfolio
  def initialize(user, portfolio_params)
    @user = user
    @portfolio_params = portfolio_params
  end

  def create_portfolio
    @portfolio = @user.portfolios.build(@portfolio_params)
    
    matching_stock = Stock.find_by(symbol: @portfolio_params[:stock_symbol])

    if matching_stock.nil?
      @portfolio.errors.add(:base, 'Invalid stock_symbol')
      return false
    end

    @portfolio.stock = matching_stock
    @portfolio.price = matching_stock.usd
    @portfolio.quantity ||= 0

    total_amount = @portfolio.price * @portfolio.quantity
    @portfolio.total_amount = total_amount

    @portfolio.save
  end
end
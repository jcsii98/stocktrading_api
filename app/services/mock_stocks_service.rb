class MockStocksService
  def fetch_available_stocks
    # Simulate available stocks for testing purposes
    [
      { id: 'valid_stock_id', name: 'Test Stock', symbol: 'TEST' },
      { id: 'valid_stock_id_1', name: 'Test Stock', symbol: 'TEST' },
      { id: 'valid_stock_id_2', name: 'Test Stock', symbol: 'TEST' },
    ]
  end

  def fetch_stock_price(stock_id)
    # Simulate stock price for testing purposes
    10.0
  end
end

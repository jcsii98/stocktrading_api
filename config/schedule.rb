env :PATH, ENV['PATH']

every 1.minute do
  runner "Stock.fetch_and_update_stock_data", environment: 'development'
end
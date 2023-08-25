env :PATH, ENV['PATH']

set :output, "./cron.log"

every 5.minute do
  runner "Stock.fetch_and_update_stock_data", environment: 'development'
end
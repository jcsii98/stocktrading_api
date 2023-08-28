# class StockWorker < ApplicationJob
#   queue_as :default

#   def perform
#     Stock.fetch_and_update_stock_data
#   end
# end
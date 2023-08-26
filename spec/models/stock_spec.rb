require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'associations' do
    it { should have_many(:portfolios) }
  end

  describe '.fetch_and_update_stock_data' do
    let(:stock_data) { [{ symbol: 'AAPL', name: 'Apple Inc.', usd: 150.0 }] }

    before do
      allow_any_instance_of(StocksService).to receive(:fetch_available_stocks).and_return(stock_data)
    end

    it 'fetches and updates stock data' do
      Stock.fetch_and_update_stock_data

      stock = Stock.find_by(symbol: 'AAPL')
      expect(stock.name).to eq('Apple Inc.')
      expect(stock.usd).to eq(150.0)
    end

    it 'skips stocks with missing symbols' do
      stock_data << { symbol: '', name: 'Missing Symbol', usd: 50.0 }

      Stock.fetch_and_update_stock_data

      stock = Stock.find_by(name: 'Missing Symbol')
      expect(stock).to be_nil
    end

    it 'handles stock update failure' do
      allow_any_instance_of(Stock).to receive(:update).and_return(false)

      Stock.fetch_and_update_stock_data
    end
  end
end

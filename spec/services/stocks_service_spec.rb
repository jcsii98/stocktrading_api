require 'rails_helper'

RSpec.describe StocksService, type: :service do
  describe '#fetch_available_stocks' do
    it 'returns a list of available stocks' do
      mock_response = [
        { 'id' => 'stock1', 'name' => 'Stock 1', 'symbol' => 'S1', 'current_price' => 100 },
        { 'id' => 'stock2', 'name' => 'Stock 2', 'symbol' => 'S2', 'current_price' => 200 }
      ]
      allow(RestClient).to receive(:get).and_return(double(body: mock_response.to_json))

      service = StocksService.new
      available_stocks = service.fetch_available_stocks

      expect(available_stocks).to eq([
        { id: 'stock1', name: 'Stock 1', symbol: 'S1', usd: 100 },
        { id: 'stock2', name: 'Stock 2', symbol: 'S2', usd: 200 }
      ])
    end

    it 'handles empty response' do
      allow(RestClient).to receive(:get).and_return(double(body: [].to_json))

      service = StocksService.new
      available_stocks = service.fetch_available_stocks

      expect(available_stocks).to eq([])
    end
  end
end

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:user) { create(:user) }
  let(:buyer_portfolio) { create(:portfolio, user: user) }
  let(:user2) { create(:user) }
  let(:seller_portfolio) { create(:portfolio, user: user2) }
  let(:transaction_quantity) { 10 }
  let(:stock_price_from_api) { 50 }


  before do
    stocks_service = MockStocksService.new
    allow(StocksService).to receive(:new).and_return(stocks_service)
  end


  describe 'validations' do
    it { should validate_presence_of(:seller_portfolio) }
    it { should validate_presence_of(:buyer_portfolio) }
    it { should validate_presence_of(:quantity) }
  end

  describe 'associations' do
    it { should belong_to(:buyer_portfolio).class_name('Portfolio') }
    it { should belong_to(:seller_portfolio).class_name('Portfolio') }
  end

  describe 'methods' do
    describe '.check_valid_entry' do
        context 'when all validations pass' do
          before do
            allow(Transaction).to receive(:validate_different_users).and_return(nil)
            allow(Transaction).to receive(:validate_positive_quantity).and_return(nil)
            allow(Transaction).to receive(:find).and_return(seller_portfolio)
            allow(seller_portfolio).to receive(:stock_id).and_return('mock_stock_id')
            allow(user.portfolios).to receive(:find_by).and_return(buyer_portfolio)
            allow(Transaction).to receive(:validate_buyer_portfolio).and_return(nil)
            allow(Transaction).to receive(:validate_covering_pending_amount).and_return(nil)
            allow(Transaction).to receive(:validate_seller_portfolio).and_return(nil)
            allow(user).to receive(:add_pending_amount).and_return(nil)
          end

          it 'returns a success hash with valid data' do
            result = Transaction.check_valid_entry(user, seller_portfolio.id, transaction_quantity)
            expect(result[:success]).to be_truthy
            expect(result[:seller_portfolio]).to eq(seller_portfolio)
            expect(result[:buyer_portfolio]).to eq(buyer_portfolio)
          end
        end
        context 'when a validation fails' do
          it 'returns a hash with success false' do
            invalid_seller_portfolio = seller_portfolio.id + 1
            result = Transaction.check_valid_entry(user, invalid_seller_portfolio, transaction_quantity )
            expect(result[:success]).to eq(false)
            expect(result[:message]).to eq('Seller portfolio does not exist')
          end
        end
      end
  end
end

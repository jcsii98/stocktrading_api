require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  let(:user) { create(:user) }

  before do
    stocks_service = MockStocksService.new
    allow(StocksService).to receive(:new).and_return(stocks_service)
  end
  
  describe 'validations' do
    it 'is valid with valid attributes' do
      portfolio = Portfolio.new(user: user, stock_id: 'mock_id', quantity: 100)
      expect(portfolio).to be_valid
    end

    it 'is invalid without a user' do
      portfolio = Portfolio.new(stock_id: 'mock_id', quantity: 100)
      expect(portfolio).to be_invalid
      expect(portfolio.errors[:user]).to include("must exist")
    end

    it 'is invalid without a stock_id' do
      portfolio = Portfolio.new(user: user, quantity: 100, stock_id: '')
      expect(portfolio).to be_invalid
      expect(portfolio.errors[:stock_id]).to include("can't be blank")
    end

    it 'is invalid with a duplicate stock_id for the same user' do
      create(:portfolio, user: user, stock_id: 'mock_id', quantity: 100)
      portfolio = Portfolio.new(user: user, stock_id: 'mock_id', quantity: 200)
      expect(portfolio).to be_invalid
      expect(portfolio.errors[:stock_id]).to include("portfolio already exists for this stock")
    end

    it 'is invalid with a negative quantity' do
      portfolio = Portfolio.new(user: user, stock_id: 'mock_id', quantity: -10)
      expect(portfolio).to be_invalid
      expect(portfolio.errors[:quantity]).to include("must be a positive number")
    end

    it 'is invalid with a blank quantity' do
      portfolio = Portfolio.new(user: user, stock_id: 'mock_id', quantity: nil)
      expect(portfolio).to be_invalid
      expect(portfolio.errors[:quantity]).to include("must be a positive number")
    end
  end

  describe 'methods' do
    describe '.check_buyer_portfolio' do
      it 'returns success if buyer portfolio exists' do
        buyer_portfolio = create(:portfolio, user: user)
        result = Portfolio.check_buyer_portfolio(user, buyer_portfolio.stock_id)
        expect(result[:success]).to be_truthy
        expect(result[:buyer_portfolio]).to eq(buyer_portfolio)
      end
      it 'returns error if buyer portfolio does not exist' do
        buyer_portfolio = create(:portfolio, user: user)
        invalid_stock_id = buyer_portfolio.stock_id + '1'
        result = Portfolio.check_buyer_portfolio(user, invalid_stock_id)

        expect(result[:success]).to eq(false)
        expect(result[:message]).to eq("Portfolio with stock_id '#{invalid_stock_id}' must exist for the current user")
      end
    end
    
    describe 'check_seller_portfolio' do
      it 'returns success if seller portfolio has sufficient quantity' do
        seller_portfolio = create(:portfolio, user: user, quantity: 100)
        result = Portfolio.check_seller_portfolio(seller_portfolio, 50)
        expect(result[:success]).to be_truthy
      end
      it 'returns error if seller portfolio has insufficient quantity' do
        seller_portfolio = create(:portfolio, user: user, quantity: 100)
        result = Portfolio.check_seller_portfolio(seller_portfolio, 101)
        expect(result[:success]).to eq(false)
        expect(result[:message]).to eq('Insufficient portfolio quantity for the transaction')
      end
    end
  end
  describe 'associations' do
    it 'has many buyer_transactions' do
      association = Portfolio.reflect_on_association(:buyer_transactions)
      expect(association.macro).to eq(:has_many)
      expect(association.class_name).to eq('Transaction')
      expect(association.foreign_key).to eq('buyer_portfolio_id')
    end
    it 'has many seller_transactions' do
      association = Portfolio.reflect_on_association(:seller_transactions)
      expect(association.macro).to eq(:has_many)
      expect(association.class_name).to eq('Transaction')
      expect(association.foreign_key).to eq('seller_portfolio_id')
    end
  end
  
end

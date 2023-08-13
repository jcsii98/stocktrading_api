require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  let(:user) { create(:user) }

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

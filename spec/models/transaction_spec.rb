require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  describe 'associations' do
    it 'should belong to user' do
      t = Portfolio.reflect_on_association(:user)
      expect(t.macro).to eq(:belongs_to)
    end

    it 'should have many buyer transactions' do
      t = Portfolio.reflect_on_association(:buyer_transactions)
      expect(t.macro).to eq(:has_many)
      expect(t.options[:class_name]).to eq('Transaction')
      expect(t.options[:foreign_key]).to eq('buyer_portfolio_id')
    end

    it 'should have many seller transactions' do
      t = Portfolio.reflect_on_association(:seller_transactions)
      expect(t.macro).to eq(:has_many)
      expect(t.options[:class_name]).to eq('Transaction')
      expect(t.options[:foreign_key]).to eq('seller_portfolio_id')
    end
  end

  describe 'validations' do
    let!(:user) { create(:user) }
    let!(:existing_portfolio) { create(:portfolio, user: user) } 

    it { should validate_uniqueness_of(:stock_id).scoped_to(:user_id).with_message('portfolio already exists for this stock') }
  end

  describe 'custom validations' do
    it 'should validate that quantity must be a positive number' do
      user = create(:user)
      portfolio = build(:portfolio, user: user, quantity: -10)
      expect(portfolio).not_to be_valid
      expect(portfolio.errors[:quantity]).to include('must be a positive number')

      portfolio.quantity = 100
      expect(portfolio).to be_valid
    end
  end

end
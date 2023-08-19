require 'rails_helper'

RSpec.describe User, type: :model do
    describe 'associations' do
        it 'should have many portfolios' do
            t = User.reflect_on_association(:portfolios)
            expect(t.macro).to eq(:has_many)
        end
    end

    describe '#full_name' do
        it 'returns the full name of the user' do
            user = create(:user, full_name: 'John Doe')
            expect(user.full_name).to eq('John Doe')
        end
    end

    describe '#user_name' do
        it 'returns the user of the user' do
            user = create(:user, user_name: 'johndoe')
            expect(user.user_name).to eq('johndoe')
        end
    end

    describe '#add_to_wallet' do
        it 'increases wallet amount by specified amount' do
            user = create(:user, wallet_balance: 100)
            user.add_to_wallet(50)

            expect(user.wallet_balance).to eq(150)
        end
    end

    describe '#can_cover_resulting_pending_amount' do
        it 'returns success hash if user can cover resulting pending amount' do
        user = create(:user, wallet_balance: 100, pending_amount: 10)
        result = user.can_cover_resulting_pending_amount(20)
        expect(result[:success]).to be_truthy
        end

        it 'returns failure hash if user cannot cover resulting pending amount' do
        user = create(:user, wallet_balance: 100, pending_amount: 10)
        result = user.can_cover_resulting_pending_amount(100)
        expect(result[:success]).to eq(false)
        expect(result[:message]).to include('User cannot cover resulting pending amount')
        end
    end

    describe '#add_pending_amount' do
        it 'increases the pending amount by the specified amount' do
            user = create(:user, pending_amount: 10)
            user.add_pending_amount(5)
            expect(user.pending_amount).to eq(15)
        end
    end

    describe '#update_wallet_balance' do
        it 'updates wallet balance by adding the amount' do
            user = create(:user, wallet_balance: 100)
            user.update_wallet_balance(50, :add)
            expect(user.wallet_balance).to eq(150)
        end

        it 'updates wallet balance by subtracting the amount' do
            user = create(:user, wallet_balance: 100)
            user.update_wallet_balance(50, :subtract)
            expect(user.wallet_balance).to eq(50)
        end

        it 'raises ArgumentError for an invalid direction' do
            user = create(:user, wallet_balance: 100)
            expect { user.update_wallet_balance(50, :invalid_direction) }.to raise_error(ArgumentError)
        end
    end

end

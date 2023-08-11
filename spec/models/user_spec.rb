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

end

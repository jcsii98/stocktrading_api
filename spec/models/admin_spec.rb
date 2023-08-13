require 'rails_helper'

RSpec.describe Admin, type: :model do

    describe '#full_name' do
        it 'returns the full name of the admin' do
            admin = create(:admin, full_name: 'John Doe')
            expect(admin.full_name).to eq('John Doe')
        end
    end

    describe '#user_name' do
        it 'returns the user of the admin' do
            admin = create(:admin, user_name: 'johndoe')
            expect(admin.user_name).to eq('johndoe')
        end
    end

end

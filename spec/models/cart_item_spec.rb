require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
        it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }

    it 'validates uniqueness of cart_id scoped to product_id' do
      cart = create(:cart)
      product = create(:product)
      create(:cart_item, cart: cart, product: product)
      
      duplicate_item = build(:cart_item, cart: cart, product: product)
      expect(duplicate_item).not_to be_valid
      expect(duplicate_item.errors[:cart_id]).to include("has already been taken")
    end
  end

  describe '#total_price' do
    it 'calculates total price correctly' do
      product = create(:product, price: 10.50)
      cart_item = create(:cart_item, product: product, quantity: 3)
      
      expect(cart_item.total_price).to eq(31.5)
    end
  end
end

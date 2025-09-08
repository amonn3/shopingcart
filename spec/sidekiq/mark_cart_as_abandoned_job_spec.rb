require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let!(:recent_cart) { create(:cart, last_interaction_at: 1.hour.ago) }
    let!(:stale_cart) { create(:cart, last_interaction_at: 4.hours.ago, abandoned: false) }
    let!(:already_abandoned_cart) { create(:cart, last_interaction_at: 4.hours.ago, abandoned: true) }
    let!(:old_abandoned_cart) { create(:cart, last_interaction_at: 8.days.ago, abandoned: true) }

    it 'marks stale carts as abandoned' do
      expect {
        subject.perform
      }.to change { stale_cart.reload.abandoned? }.from(false).to(true)
    end

    it 'does not mark recent carts as abandoned' do
      expect {
        subject.perform
      }.not_to change { recent_cart.reload.abandoned? }
    end

    it 'removes old abandoned carts' do
      expect {
        subject.perform
      }.to change { Cart.exists?(old_abandoned_cart.id) }.from(true).to(false)
    end

    it 'does not remove recently abandoned carts' do
      expect {
        subject.perform
      }.not_to change { Cart.exists?(already_abandoned_cart.id) }
    end

    it 'returns correct counts' do
      result = subject.perform
      
      expect(result[:marked_as_abandoned]).to eq(1)
      expect(result[:removed_carts]).to eq(1)
    end

    it 'logs the results' do
      expect(Rails.logger).to receive(:info).with("Marked 1 carts as abandoned")
      expect(Rails.logger).to receive(:info).with("Removed 1 old abandoned carts")
      
      subject.perform
    end
  end
end

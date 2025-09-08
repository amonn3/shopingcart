FactoryBot.define do
  factory :cart do
    total_price { 0.0 }
    abandoned { false }
    last_interaction_at { Time.current }
    session_id { SecureRandom.hex(16) }

    factory :shopping_cart do
      # Alias for better test readability
    end

    factory :abandoned_cart do
      abandoned { true }
      last_interaction_at { 4.hours.ago }
    end

    factory :old_abandoned_cart do
      abandoned { true }
      last_interaction_at { 8.days.ago }
    end
  end
end

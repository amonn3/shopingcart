class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0, allow_nil: true

  scope :abandoned, -> { where(abandoned: true) }
  scope :not_abandoned, -> { where(abandoned: false) }
  scope :inactive_since, ->(time) { where('last_interaction_at < ?', time) }

  def total_price
    cart_items.sum(&:total_price)
  end

  def add_product(product, quantity)
    current_item = cart_items.find_by(product: product)
    
    if current_item
      current_item.quantity += quantity
      current_item.save!
    else
      cart_items.create!(product: product, quantity: quantity)
    end
    
    touch_interaction
  end

  def remove_product(product)
    cart_item = cart_items.find_by(product: product)
    return false unless cart_item
    
    cart_item.destroy!
    touch_interaction
    true
  end

  def update_product_quantity(product, quantity)
    cart_item = cart_items.find_by(product: product)
    return false unless cart_item
    
    if quantity <= 0
      cart_item.destroy!
    else
      cart_item.update!(quantity: quantity)
    end
    
    touch_interaction
    true
  end

  def abandoned?
    abandoned
  end

  def mark_as_abandoned
    update!(abandoned: true)
  end

  def remove_if_abandoned
    return false unless abandoned?
    return false unless last_interaction_at && last_interaction_at < 7.days.ago
    
    destroy!
    true
  end

  def should_be_abandoned?
    return false unless last_interaction_at
    last_interaction_at < 3.hours.ago
  end

  def to_json_response
    {
      id: id,
      products: cart_items.includes(:product).map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price.to_f,
          total_price: item.total_price.to_f
        }
      end,
      total_price: total_price.to_f
    }
  end

  private

  def touch_interaction
    update_column(:last_interaction_at, Time.current)
  end
end

class CartsController < ApplicationController
  before_action :set_current_cart, only: [:show, :create, :add_item, :destroy]
  before_action :find_product, only: [:create, :add_item, :destroy]

  # GET /cart
  def show
    if @current_cart
      render json: @current_cart.to_json_response, status: :ok
    else
      render json: { 
        id: nil, 
        products: [], 
        total_price: 0.0 
      }, status: :ok
    end
  end

  # POST /cart
  def create
    return render_error("Product not found", :not_found) unless @product
    return render_error("Quantity must be greater than 0", :unprocessable_entity) if params[:quantity].to_i <= 0

    @current_cart ||= create_cart_for_session
    
    begin
      @current_cart.add_product(@product, params[:quantity].to_i)
      render json: @current_cart.to_json_response, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render_error(e.message, :unprocessable_entity)
    end
  end

  # POST /cart/add_item
  def add_item
    return render_error("Product not found", :not_found) unless @product
    return render_error("Cart not found", :not_found) unless @current_cart
    return render_error("Quantity must be greater than 0", :unprocessable_entity) if params[:quantity].to_i <= 0

    begin
      cart_item = @current_cart.cart_items.find_by(product: @product)
      
      if cart_item
        new_quantity = cart_item.quantity + params[:quantity].to_i
        @current_cart.update_product_quantity(@product, new_quantity)
      else
        @current_cart.add_product(@product, params[:quantity].to_i)
      end
      
      render json: @current_cart.to_json_response, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render_error(e.message, :unprocessable_entity)
    end
  end

  # DELETE /cart/:product_id
  def destroy
    return render_error("Cart not found", :not_found) unless @current_cart
    return render_error("Product not found", :not_found) unless @product

    if @current_cart.remove_product(@product)
      render json: @current_cart.to_json_response, status: :ok
    else
      render_error("Product not found in cart", :not_found)
    end
  end

  private

  def set_current_cart
    @current_cart = find_cart_by_session
  end

  def find_cart_by_session
    return nil unless session[:cart_id]
    Cart.find_by(id: session[:cart_id])
  end

  def create_cart_for_session
    cart = Cart.create!(last_interaction_at: Time.current, session_id: session.id.to_s)
    session[:cart_id] = cart.id
    cart
  end

  def find_product
    @product = Product.find_by(id: params[:product_id])
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end

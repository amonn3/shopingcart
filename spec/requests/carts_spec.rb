require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let!(:product) { create(:product, name: "Test Product", price: 10.0) }
  let!(:another_product) { create(:product, name: "Another Product", price: 15.0) }
  
  # Helper method to make requests with session persistence
  def json_request(method, path, params = {})
    send(method, path, params: params, as: :json)
  end

  describe "GET /cart" do
    context "when no cart exists" do
      it "returns empty cart response" do
        get '/cart'
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          'id' => nil,
          'products' => [],
          'total_price' => 0.0
        )
      end
    end

    context "when cart exists with products" do
      before do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
      end

      it "returns cart with products" do
        get '/cart'
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].size).to eq(1)
        expect(json_response['total_price']).to eq(20.0)
      end
    end
  end

  describe "POST /cart" do
    context "when adding a new product" do
      it "creates a new cart and adds the product" do
        expect {
          post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        }.to change(Cart, :count).by(1)
          .and change(CartItem, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].size).to eq(1)
        expect(json_response['total_price']).to eq(20.0)
      end
    end

    context "when product doesn't exist" do
      it "returns not found error" do
        post '/cart', params: { product_id: 999, quantity: 1 }, as: :json
        
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Product not found')
      end
    end

    context "when quantity is invalid" do
      it "returns unprocessable entity for zero quantity" do
        post '/cart', params: { product_id: product.id, quantity: 0 }, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Quantity must be greater than 0')
      end

      it "returns unprocessable entity for negative quantity" do
        post '/cart', params: { product_id: product.id, quantity: -1 }, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Quantity must be greater than 0')
      end
    end

    context "when adding existing product" do
      before do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it "increases quantity of existing product" do
        expect {
          post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        }.not_to change(CartItem, :count)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['quantity']).to eq(3)
      end
    end
  end

  describe "POST /cart/add_item" do
    context "when cart exists" do
      before do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      context "when the product already is in the cart" do
        it 'updates the quantity of the existing item in the cart' do
          post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['products'].first['quantity']).to eq(2)
        end
      end

      context "when adding a new product to existing cart" do
        it 'adds the new product to cart' do
          post '/cart/add_item', params: { product_id: another_product.id, quantity: 1 }, as: :json
          
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['products'].size).to eq(2)
        end
      end
    end

    context "when cart doesn't exist" do
      it "returns cart not found error" do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Cart not found')
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    context "when cart exists with the product" do
      let!(:cart) { Cart.create!(last_interaction_at: Time.current, session_id: 'test_session') }
      let!(:cart_item1) { CartItem.create!(cart: cart, product: product, quantity: 2) }
      let!(:cart_item2) { CartItem.create!(cart: cart, product: another_product, quantity: 1) }
      
      before do
        # Simulate session by setting the cart_id directly
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      end

      it "removes the product from cart" do
        expect {
          delete "/cart/#{product.id}"
        }.to change(CartItem, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['products'].size).to eq(1)
        expect(json_response['products'].first['id']).to eq(another_product.id)
      end
    end

    context "when product is not in cart" do
      let!(:cart) { Cart.create!(last_interaction_at: Time.current, session_id: 'test_session') }
      let!(:cart_item) { CartItem.create!(cart: cart, product: another_product, quantity: 1) }
      
      before do
        # Simulate session by setting the cart_id directly
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      end

      it "returns product not found in cart error" do
        delete "/cart/#{product.id}"
        
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Product not found in cart')
      end
    end

    context "when cart doesn't exist" do
      it "returns cart not found error" do
        delete "/cart/#{product.id}"
        
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Cart not found')
      end
    end
  end
end

class Api::V1::ProductOrdersController < ApplicationController
  before_action :set_user, only: [:create]

  def create
    return render json: { message: "Unauthorized" }, status: 403 if !@user
    
    @order = cart_opened(@user)
    @product = Product.find(params[:product_id])
    amount = params[:amount].to_i

    if @order.blank?
      @order = Order.create(
        user_id: @user.id,
        total_price: @product.price * amount
      )
  
      ProductOrder.create(
        product_id: @product.id,
        user_id: @user.id,
        order_id: @order.id,
        amount: amount
      )
    else
      ProductOrder.create(
        product_id: @product.id,
        user_id: @user.id,
        order_id: @order.id,
        amount: amount
      )

      @order.update(
        total_price: @order.total_price + (@product.price * amount)
      )
    end

    render json: { message: "Order updated", data: {
      order: @order, 
      product_orders: @order.product_orders.map do |order|
        {
          id: order.id,
          product_id: order.product_id,
          product_name: Product.find(order.product_id).name,
          product_price: Product.find(order.product_id).price,
          product_photo: Product.find(order.product_id).photos.present? ? Product.find(order.product_id).photos[0].url : "",
          order_id: order.order_id,
          user_id: order.user_id,
          amount: order.amount,
          created_at: order.created_at,
          updated_at: order.updated_at
        }
      end
    } }, status: :ok
  end

  private

  def cart_opened(user)
    @order = Order.find_by(user_id: user.id, cart_is_opened: true)
  end

  def set_user
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last
    @user = User.find_by(magic_link_token: token)
  end

  def product_orders_params
    params.require(:product_order).permit(
      :user_id,
      :product_id
    )
  end
end

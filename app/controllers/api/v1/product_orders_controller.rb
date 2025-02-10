class Api::V1::ProductOrdersController < ApplicationController
  before_action :set_user, only: [:create]

  def create
    return render json: { message: "Unauthorized" }, status: :forbidden unless @user
  
    @order = cart_opened(@user)
    @product = Product.find(params[:product_id])
    amount = params[:amount].to_i
  
    begin
      ActiveRecord::Base.transaction do
        if @order.blank?
          @order = Order.create!(
            user_id: @user.id,
            total_price: @product.price * amount
          )
  
          ProductOrder.create!(
            product_id: @product.id,
            user_id: @user.id,
            order_id: @order.id,
            amount: amount
          )
        else
          ProductOrder.create!(
            product_id: @product.id,
            user_id: @user.id,
            order_id: @order.id,
            amount: amount
          )
  
          @order.update!(
            total_price: @order.total_price + (@product.price * amount)
          )
        end
      end
  
      render json: { message: "Order updated", order: @order }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
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

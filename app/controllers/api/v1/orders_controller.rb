class Api::V1::OrdersController < ApplicationController
  def create
    
  end

  def show
    @order = Order.find(params[:id])
  end
end

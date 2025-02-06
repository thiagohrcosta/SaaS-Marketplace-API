class Api::V1::CategoriesController < ApplicationController
  before_action :authorize_admin, only: [:create, :update, :destroy]
  before_action :set_category, only: [:update, :destroy]

  def create
    @category = Category.new(category_params)
    if @category.save
      render json: { message: "Category created", data: @category }, status: :ok
    else
      render json: { message: "Error while creating a company" }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: { message: "Category updated", data: @category }, status: :ok
    else
      render json: { message: "Error while updating the category" }, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      render json: { message: "Category deleted" }, status: :ok
    else
      render json: { message: "Error while tyring to delete the category" }, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def authorize_admin
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last
    @user = User.find_by(magic_link_token: token)

    unless @user&.role == "admin"
      render json: { error: "Action not allowed" }, status: :unauthorized
    end
  end

  def category_params
    params.require(:category).permit(:name)
  end
end

class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  def index
    @products = Product.all.where(is_available: true).map do |product|
      {
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        discount_percentage: product.discount_percentage,
        company_id: product.company_id,
        category_id: product.company_id,
        photos: product.photos.map { |photo| photo.url },
        created_at: product.created_at,
        updated_at: product.updated_at
      }
    end
    render json: @products
  end

  def create
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last
    @user = User.find_by(magic_link_token: token)
    @company_user = CompanyUser.find_by(user_id: @user.id)
    @company = Company.find(@company_user.company_id)

    @product = Product.new(product_params)
    @product.company_id = @company.id

    if @product.save
      return render json: { message: "Product created", data: @product }, status: :ok
    else
      return render json: { message: "Erro while creating product"}, status: :unprocessable_entity
    end
  end

  def show
    render json: @product = {
      id: @product.id,
      name: @product.name,
      description: @product.description,
      price: @product.price,
      discount_percentage: @product.discount_percentage,
      company_id: @product.company_id,
      category_id: @product.company_id,
      photos: @product.photos.map { |photo| photo.url },
      created_at: @product.created_at,
      updated_at: @product.updated_at
    }
  end

  def update
    return render json: { message: "Unauthorized" }, status: 403 unless user_is_authorized?
  
    if params[:product].blank?
      return render json: { message: "Invalid parameters" }, status: 403
    end
  
    if @product.update(product_params)
      render json: { message: "Product updated", data: @product }, status: :ok
    else
      render json: { message: "Error while updating a product" }, status: :unprocessable_entity
    end
  end
  def destroy
    return render json: { message: "Unauthorized"}, status: 403 if user_is_authorized? == false

    if @product.destroy
      return render json: { message: "Product deleted" }, status: :ok
    else
      return render json: { message: "Erro while deleting a product"}, status: :unprocessable_entity
    end
  end

  private

  def user_is_authorized?
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last
    @user = User.find_by(magic_link_token: token)

    return false if !@user

    @company_user = CompanyUser.find_by(user_id: @user.id)

    return false if !@company_user

    @company = Company.find(@company_user.company_id)
    @company_user.company_id == @company.id ? true : false
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.fetch(:product).permit(
      :name, 
      :description,
      :price,
      :discount_percentage,
      :stock_amount,
      :company_id,
      :category_id,
      photos: []
    )
  end
end

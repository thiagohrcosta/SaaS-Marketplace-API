class Api::V1::CompaniesController < ApplicationController
  before_action :authorize_user, only: [:create, :update]
  before_action :set_company, only: [:update]

  def create
    return render json: { message: "Company params are required" }, status: :unprocessable_entity if params[:company].blank?
    return render json: { message: "Company must have a name" }, status: :unprocessable_entity if params[:company][:name].blank?
    return render json: { message: "Company already exists" }, status: :unprocessable_entity if Company.exists?(name: params[:company][:name])
    
    ActiveRecord::Base.transaction do
      @company = Company.create!(company_params)

      CompanyUser.create!(
        company_id: @company.id,
        user_id: @user.id
      )

      render json: { message: "Company created", data: @company }, status: :ok
    end
  rescue ActiveRecord::RecordInvalid
    render json: { message: "Error while creating a company" }, status: :unprocessable_entity
  end

  def update
    if user_belongs_to_company?(@user, @company) == true
      if @company.update(company_params)
        render json: { message: "Company updated", data: @company }, status: :ok
      else
        render json: { message: "Error while updating a company" }, status: :unprocessable_entity
      end
    else
      render json: { message: "Unauthorized" }, status: 401
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def user_belongs_to_company?(user, company)
    user_belongs_to_company = CompanyUser.find_by(user_id: user.id, company_id: company.id)
    user_belongs_to_company ? true : false
  end

  def authorize_user
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last
    @user = User.find_by(magic_link_token: token)

    unless @user&.role == "company"
      render json: { error: "Action not allowed" }, status: :unauthorized
    end
  end

  def company_params
    params.require(:company).permit(:name)
  end
end

class Api::V1::CompaniesController < ApplicationController
  before_action :authorize_user, only: [:create]

  def create
    ActiveRecord::Base.transaction do
      @company = Company.create!(company_params)

      CompanyUsers.create!(
        company_id: @company.id,
        user_id: current_user.id
      )

      render json: { message: "Company created", data: @company }, status: :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

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
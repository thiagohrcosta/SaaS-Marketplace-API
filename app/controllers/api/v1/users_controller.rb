class Api::V1::UsersController < ApplicationController

  def profile
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last
  
    @user = User.find_by(magic_link_token: token)
  

    if @user 
      render json: {
        email: @user.email,
        full_name: @user.full_name,
        role: @user.role
      }
    else
      render json: { error: "User not found" }, status: :unprocessable_entity
    end
  end
  
  def create
    user = User.new(user_params)

    if user.save
      user.update(magic_link_token: SecureRandom.hex(32))
      generate_magic_link(user)

      render json: { message: "Check your email for the magic link!" }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :full_name, :role)
  end

  def generate_magic_link(user)
    @user = user
    # root_url = "http://localhost:3000/api/v1/"
    binding.pry
    @magic_link = "http://localhost:3000/api/v1/login?token=#{@user.magic_link_token}&email=#{@user.email}"
    puts @magic_link
    # mail(to: @user.email, subject: 'Your Magic Link for Login')
  end
  
end
class Api::V1::SessionsController < ApplicationController
  def login_with_magic_link
    user = User.find_by(magic_link_token: params[:token])

    if !user
      @user = User.find_by(email: params[:email])
      if @user
        generate_magic_link(@user)
        return render json: { message: "Check your email for the magic link!" }, status: :ok
      else
        return render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    if user
      # user.update(magic_link_token: user.magic)
      render json: { message: "Logged in successfully" }, status: :ok
    else
      render json: { error: "Invalid or expired token" }, status: :unauthorized
    end
  end

  private

  def generate_magic_link(user)
    @user = user
    @user.update(magic_link_token: SecureRandom.hex(32))

    root_url = "http://localhost:3000/api/v1/"

    @magic_link = "http://localhost:3000/api/v1/login?token=#{@user .magic_link_token}&email=#{@user .email}"
    puts @magic_link
    # mail(to: @user.email, subject: 'Your Magic Link for Login')
  end
end
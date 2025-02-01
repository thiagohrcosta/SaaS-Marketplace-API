require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  let(:user) { create(:user) } 

  describe "GET /api/v1/profile" do
    it "Should return the user profile" do
      get api_v1_profile_path, headers: valid_headers(user)

      expect(response).to have_http_status(200)

      json_response = JSON.parse(response.body)
      expect(json_response).to include(
        "email" => user.email,
        "full_name" => user.full_name,
        "role" => user.role
      )
    end

    it "Should return 'User not found'" do
      allow(User).to receive(:find_by).and_return(nil) 

      get api_v1_profile_path, headers: valid_headers(user)

      expect(response).to have_http_status(422)

      json_response = JSON.parse(response.body)
      expect(json_response).to include(
        "error" => "User not found"
      )
    end
  end

  describe "POST /api/v1/users" do
    it "Should create user" do
      post api_v1_users_path, 
           params: { user: { email: "test@user.com", full_name: "Test User", role: "company" } }.to_json, 
           headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(200)

      json_response = JSON.parse(response.body)
      expect(json_response).to include(
        "message" => "Check your email for the magic link!"
      )
    end

    it "Should not create user" do
      post api_v1_users_path, 
           params: { user: { full_name: "Test User", role: "company" } }.to_json, 
           headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(422)

      json_response = JSON.parse(response.body)
      expect(json_response).to include(
        "error" => "Error while trying to create user"
      )
    end
  end
end

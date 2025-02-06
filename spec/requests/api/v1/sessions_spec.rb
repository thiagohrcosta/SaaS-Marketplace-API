require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  let(:user) { create(:user, role: 'company', magic_link_token: 'valid_token') }
  let(:headers) { { 'Authorization' => "saas_token #{user.magic_link_token}" } }

  describe "POST /api/v1/login" do
    context "with valid magic_link_token" do
      it "logs in successfully" do
        post "/api/v1/login", params: { token: user.magic_link_token }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Logged in successfully")
      end
    end

    context "with invalid magic_link_token" do
      it "returns an error for an invalid token" do
        post "/api/v1/login", params: { token: "invalid_token" }, headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
      end
    end

    context "when user does not exist but email is provided" do
      it "sends a magic link to the email if user exists" do
        existing_user = create(:user, email: "test@example.com")
        allow_any_instance_of(Api::V1::SessionsController).to receive(:generate_magic_link)

        post "/api/v1/login", params: { token: nil, email: existing_user.email }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Check your email for the magic link!")
      end
    end

    describe "#generate_magic_link" do
      it "generates a new magic link token for the user" do
        old_token = user.magic_link_token
        controller = Api::V1::SessionsController.new
        controller.send(:generate_magic_link, user)

        expect(user.reload.magic_link_token).not_to eq(old_token)
        expect(user.magic_link_token).not_to be_nil
      end

      it "creates a valid magic link URL" do
        controller = Api::V1::SessionsController.new
        allow(SecureRandom).to receive(:hex).and_return("test_token")

        controller.send(:generate_magic_link, user)

        expected_link = "http://localhost:3000/api/v1/login?token=test_token&email=#{user.email}"
        expect(controller.instance_variable_get(:@magic_link)).to eq(expected_link)
      end
    end
  end
end

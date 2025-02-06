require 'rails_helper'

RSpec.describe "Api::V1::Companies", type: :request do
  let(:user) { create(:user, role: 'company', magic_link_token: 'my_token') }
  let(:headers) { { 'Authorization' => "saas_token #{user.magic_link_token}" } }
  let(:valid_attributes) { { company: { name: "Test Company" } } }
  let(:unvalid_attributes) { { company: {}}}

  describe "POST /api/v1/companies" do
    before { user }

    it "creates a company and associates the user" do
      expect {
        post '/api/v1/companies', params: valid_attributes, headers: headers
      }.to change(Company, :count).by(1)
    end

    it "gets unauthorized without saas_token" do
      post '/api/v1/companies', params: valid_attributes
    
      expect(response).to have_http_status(401)
    end

    it "return error withtout company params" do
      post '/api/v1/companies', params: unvalid_attributes, headers: headers

      expect(response).to have_http_status(422)
    end

    it "returns an error when company creation fails" do
      allow(Company).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Company.new))
    
      post '/api/v1/companies', params: { company: { name: "Test Company" } }, headers: headers
    
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)["message"]).to eq("Error while creating a company")
    end
    
  end
end

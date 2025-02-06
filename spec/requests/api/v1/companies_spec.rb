require 'rails_helper'

RSpec.describe "Api::V1::Companies", type: :request do
  let(:user) { create(:user, role: 'company', magic_link_token: 'my_token') }
  let(:headers) { { 'Authorization' => "saas_token #{user.magic_link_token}" } }
  let(:valid_attributes) { { company: { name: "Test Company" } } }
  
  describe "POST /api/v1/companies" do
    before { user }

    it "creates a company and associates the user" do
      binding.pry
      expect {
        post '/api/v1/companies', params: valid_attributes, headers: headers
      }.to change(Company, :count).by(1)
    end
  end
end

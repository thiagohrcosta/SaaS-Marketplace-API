require 'rails_helper'

RSpec.describe "Api::V1::Companies", type: :request do
  let(:user) { create(:user, role: 'company', magic_link_token: 'my_token') }
  let(:headers) { { 'Authorization' => "saas_token #{user.magic_link_token}" } }
  let(:valid_attributes) { { company: { name: "Test Company" } } }

  let(:second_user) { create(:user, email: "test2@email.com", role: 'company', magic_link_token: 'my_token2') }
  let(:second_headers) { { 'Authorization' => "saas_token #{second_user.magic_link_token}" } }

  let(:company) { create(:company)}
  let!(:company_user) { create(:company_user, company_id: company.id, user_id: second_user.id) }

  let(:unvalid_attributes) { { company: {}}}

  describe "POST /api/v1/companies" do
    before { user }

    it "should create a company and associates the user" do
      expect {
        post '/api/v1/companies', params: valid_attributes, headers: headers
      }.to change(Company, :count).by(1)
    end

    it "should get unauthorized without saas_token" do
      post '/api/v1/companies', params: valid_attributes
    
      expect(response).to have_http_status(401)
    end

    it "should return error withtout company params" do
      post '/api/v1/companies', params: unvalid_attributes, headers: headers

      expect(response).to have_http_status(422)
    end

    it "should return an error when company creation fails" do
      allow(Company).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Company.new))
    
      post '/api/v1/companies', params: { company: { name: "Test Company" } }, headers: headers
    
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)["message"]).to eq("Error while creating a company")
    end
  end
  describe "PATCH /api/v1/companies/:id" do
    before { company_user } # Garante que o usuário pertence à empresa
  
    it "should update a company" do
      valid_attributes[:company][:name] = "Updated Company Name"
  
      patch "/api/v1/companies/#{company.id}", params: valid_attributes, headers: second_headers
  
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["data"]["name"]).to eq("Updated Company Name")
    end
  
    it "should return error when params are invalid" do
      patch "/api/v1/companies/#{company.id}", params: { company: nil }, headers: second_headers
    
      expect(response).to have_http_status(400)
    end

    it "should return an error when company update fails" do
      allow_any_instance_of(Company).to receive(:update).and_return(false)
    
      patch "/api/v1/companies/#{company.id}", params: valid_attributes, headers: second_headers
    
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)["message"]).to eq("Error while updating a company")
    end
  
    it "should return unauthorized when user does not belong to the company" do
      patch "/api/v1/companies/#{company.id}", params: valid_attributes, headers: headers
  
      expect(response).to have_http_status(401)
      expect(JSON.parse(response.body)["message"]).to eq("Unauthorized")
    end
  
    it "should return unauthorized when no saas_token is provided" do
      patch "/api/v1/companies/#{company.id}", params: valid_attributes
  
      expect(response).to have_http_status(401)
    end
  end

end

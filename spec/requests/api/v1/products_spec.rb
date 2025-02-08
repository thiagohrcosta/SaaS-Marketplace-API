require 'rails_helper'

RSpec.describe "Api::V1::Products", type: :request do
  describe "GET /api/v1/products" do
    let!(:products) { create_list(:product, 10) }

    it "returns all products" do
      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)

      expect(json_response.size).to eq(10)
    end
  end

  describe "GET /api/v1/products/:id" do
    let!(:products) { create_list(:product, 10) }
  
    it "should return information about one product" do
      get "/api/v1/products/#{products.first.id}"
  
      expect(response).to have_http_status(:ok)
  
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(products.first.id) 
    end
  end

  describe "PATCH /api/v1/products/:id" do 
    let(:user) { create(:user, role: 'company', magic_link_token: 'my_token') }
    let(:company) { create(:company) }
    let!(:company_user) { create(:company_user, company: company, user: user) }
    let(:headers) { { 'Authorization' => "saas_token #{user.magic_link_token}" } }

    let(:other_user) { create(:user, email: "unique_#{SecureRandom.hex(4)}@test.com", role: 'company', magic_link_token: 'other_token') }

    let(:product) { create(:product, company: company) }

    let(:valid_attributes) { { product: { name: "Updated Product Name" } } }
    let(:invalid_attributes) { { product: { name: "" } } }

    it "should update the product when user is authorized" do
      patch "/api/v1/products/#{product.id}", params: valid_attributes, headers: headers

      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response["data"]["name"]).to eq("Updated Product Name")

      expect(product.reload.name).to eq("Updated Product Name")
    end

    it "should return an error when update fails" do
      allow_any_instance_of(Product).to receive(:update).and_return(false)
      
      patch "/api/v1/products/#{product.id}", params: valid_attributes, headers: headers

      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)["message"]).to eq("Error while updating a product")
    end

    it "should return unauthorized when user does not belong to the company" do
      other_user_2 = create(:user, role: 'company', magic_link_token: "other_token_#{rand(0..1000)}")
      other_headers_2 = { 'Authorization' => "saas_token #{other_user_2.magic_link_token}" }

      patch "/api/v1/products/#{product.id}", params: valid_attributes, headers: other_headers_2

      expect(response).to have_http_status(403)
      expect(JSON.parse(response.body)["message"]).to eq("Unauthorized")
    end

    it "should return unauthorized when when params are invalid" do
      other_user_3 = create(:user, role: 'company', magic_link_token: "other_token_#{rand(0..1000)}")
      other_headers_3 = { 'Authorization' => "saas_token #{other_user_3.magic_link_token}" }
      
      patch "/api/v1/products/#{product.id}", params: invalid_attributes, headers: other_headers_3

      expect(response).to have_http_status(403)
    end
  end
end

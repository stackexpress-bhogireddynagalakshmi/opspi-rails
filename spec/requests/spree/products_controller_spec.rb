require 'rails_helper'


RSpec.describe Spree::Admin::ProductsController, type: :controller do
  before(:each) { @routes = Spree::Core::Engine.routes }
  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }
  #Super Admin Store
 
  let(:admin_user) { create(:spree_user,:with_super_admin_role,password: 'opspi@123') }
  let(:admin_store) {create(:spree_store,url: 'example.com')}


  context "store [example.com]" do
    before(:each) do
      @request.host = admin_store.url #example.com
    end

    context '#create session for super admin' do
      it 'using correct login information on admin store' do
        post :create, params: { spree_user: { email: admin_user.email ,password: 'opspi@123'} }
        expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(302)
      end
    end

    context '#crud  for super admin' do
      it "creates a Product" do
        post :create, params: { spree_product: { name: "nsbsb" ,available_on: Date.today, server_type: "reseller_plan", price: 100, account_id: admin_store.account.id} }
        expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(302)
      end

      it "list products" do
        get :index
        expect(response.status).to eq(302)
        # expect(response).to have_http_status(:success)
        # expect(flash[:success]).to eq("")  
      end

      # it "Delete a product" do
      #   product_new =  create(:spree_product)
      #   byebug
      #   delete :destroy, params: { spree_product: { id: product_new.name}}
      # end

      # it "updates a Product" do
      #   put :update, params: { spree_product: { name: "nsbsb" ,available_on: Date.today, server_type: "reseller_plan", price: 110, account_id: admin_store.account.id} }
      #   expect(flash[:error]).to eq(nil)
      #   expect(response.status).to eq(302)
      # end
    end
  end

end


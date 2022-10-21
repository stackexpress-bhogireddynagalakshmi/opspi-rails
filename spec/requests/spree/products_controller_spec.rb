require 'rails_helper'


RSpec.describe Spree::Admin::ProductsController, type: :controller do
  before(:each) { @routes = Spree::Core::Engine.routes }
  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }
  #Super Admin Store
 
    let(:admin_user) { create(:spree_user,:with_super_admin_role,password: 'opspi@123') }
    let(:admin_store) {create(:spree_store,url: 'example.com')}
    

    let(:store_admin) { create(:spree_user,:with_store_admin_role,password: 'opspi@123') }
    let(:reseller_store) { create(:spree_store,url: 'reseller10.example.com', admin_email: store_admin.email,name: "Reseller Store") }
    let(:account) {admin_store.account}

    let(:reseller_product) { create(:spree_product, server_type: 'reseller_plan',account: reseller_store.account)}
    let(:subscription) {create(:subscription,user: store_admin,plan:reseller_product)}


  context "store [example.com]" do
    before(:each) do
      @request.host = admin_store.url #example.com
    end

    context '#create session for super admin' do
      it 'using correct login information on admin store' do
        post :create, params: { spree_user: { email: admin_user.email ,password: 'opspi@123'} }
        expect(flash[:error]).to eq(nil)
        # expect(flash[:success]).to eq("Logged in successfully")
      end
    end


    it 'payment capture by super admin' do
      byebug
      # put :fire, params: { payment: {e: "capture", order_id: , id: }}
    end

  end

  # it "creates a Product and redirects to the Product index page" do
  #   post :create, params: { spree_product: { name: "nsbsb" ,available_on: Date.today, server_type: "reseller_plan", price: 100, account_id: admin_store.account.id} }
  #   expect(flash[:error]).to eq(nil)
  #   # expect(flash[:success]).to eq("")  
  # end

end


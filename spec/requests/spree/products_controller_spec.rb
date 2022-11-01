require 'rails_helper'


RSpec.describe Spree::Admin::ProductsController, type: :controller do
  let(:admin_user) { create(:spree_user,:with_super_admin_role,password: 'opspi@123') }
  let(:admin_store) {create(:spree_store,admin_email: admin_user.email,url: 'example.com', solid_cp_master_plan_id: 121)}

  before(:each) { @routes = Spree::Core::Engine.routes }
  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }

  before do
    controller.stub(:current_spree_user => admin_user)
  end
  

  before(:each) do
    @request.host = admin_store.url #example.com
  end

  # before(:each) do
  #   stub_authorization!
  # end
  #Super Admin Store
  # login_super_admin

  # it "should have a current_user" do
  #   expect(subject.current_spree_user).to_not eq(nil)
  # end

  context "store [example.com]" do
    

    context '#crud  for super admin' do

      before(:each) do
        @product = create(:product, account: admin_store.account)
      end

      it "creates a Product" do
        post :create, params: { product: { id: 2, name: "Rory" ,available_on: Date.today, server_type: "reseller_plan", price: 100} }
        expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(302)
        # expect(ProductConfig.find_by_product_id(2)).to be_truthy
      end

      it "list all products" do
        get :index
        expect(response.status).to eq(200)
      end

      it "show a product" do
        get :show, params: { id: @product.slug}
        expect(response).to redirect_to(edit_admin_product_path(@product.slug))
      end

      it "Delete a product" do
        delete :destroy, params: { id: @product.slug}
        expect(response.status).to eq(302)
        expect(Spree::Product.find_by(slug: @product.slug)).to be_falsey
      end

      it "updates a Product" do
        put :update, params: { id: @product.slug, product: { name: "Rory", price: 110} }
        # expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(302)
      end
    end
  end

end


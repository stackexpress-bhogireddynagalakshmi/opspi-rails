require 'rails_helper'


RSpec.describe Spree::Admin::ProductsController, type: :controller do
  before(:each) { @routes = Spree::Core::Engine.routes }

  #Super Admin Store
  login_super_admin

  it "should have a current_user" do
    expect(subject.current_spree_user).to_not eq(nil)
  end
  # let(:admin_user) { create(:spree_user,:with_super_admin_role,password: 'opspi@123') }
  let(:admin_store) {create(:spree_store,admin_email: subject.current_spree_user.email,url: 'example.com')}

  # context '#create session for super admin' do
  #     it 'using correct login information on admin store' do
  #       post :create, params: { spree_user: { email: admin_user.email ,password: 'opspi@123'} }
  #       expect(flash[:error]).to eq(nil)
  #       expect(response.status).to eq(200)
  #       # expect(flash[:success]).to eq("Logged in successfully")
  #     end
  #   end


  context "store [example.com]" do
    before(:each) do
      @request.host = admin_store.url #example.com
    end

    context '#crud  for super admin' do

      before(:each) do
        @product = create(:product, account_id: admin_store.account.id)
      end

      it "creates a Product" do
        post :create, params: { product: { id: 2, name: "Rory" ,available_on: Date.today, server_type: "reseller_plan", price: 100, account_id: admin_store.account.id} }
        expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(200)
        expect(ProductConfig.find_by_product_id(2)).to be_truthy
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
        expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(302)
      end
    end
  end

end


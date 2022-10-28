require 'rails_helper'


RSpec.describe Spree::Admin::ProductsController, type: :controller do
  before(:each) { @routes = Spree::Core::Engine.routes }

  login_super_admin

  #Super Admin Store
  it "should have a current_user" do
    expect(subject.current_spree_user).to_not eq(nil)
  end

  let(:admin_store) {create(:spree_store,admin_email: subject.current_spree_user.email,url: 'example.com')}


  context "store [example.com]" do
    before(:each) do
      @request.host = admin_store.url #example.com
    end

    context '#crud  for super admin' do
      it "creates a Product" do
        post :create, params: { product: { name: "Rory" ,available_on: Date.today, server_type: "reseller_plan", price: 100, account_id: admin_store.account.id} }
        expect(flash[:error]).to eq(nil)
        expect(response.status).to eq(200)
      end

      it "list products" do
        get :index
        expect(response.status).to eq(200)
      end

      it "Delete a product" do
        @product =  Spree::Product.create(name: "Rory" ,available_on: Date.today, server_type: "reseller_plan", price: 100, account_id: admin_store.account.id)
        delete :destroy, params: { id: @product.slug}
        expect(response.status).to eq(302)
        # expect(Spree::Product.where(slug: @product.slug)).to eq(nil)
      end

      it "updates a Product" do
        @product =  Spree::Product.create(name: "Rory" ,available_on: Date.today, server_type: "reseller_plan", price: 100, account_id: admin_store.account.id)
        put :update, params: { id: @product.slug, product: { name: "Rory1" ,available_on: Date.today, server_type: "reseller_plan", price: 110, account_id: admin_store.account.id} }
        # Spree::Product.where(slug: @product.slug)
        expect(flash[:error]).to eq("Product is not found")
        # expect(response.status).to eq(302)
      end
    end
  end

end


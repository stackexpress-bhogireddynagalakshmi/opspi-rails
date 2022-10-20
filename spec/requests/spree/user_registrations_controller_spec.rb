require 'rails_helper'

RSpec.describe Spree::UserRegistrationsController, type: :controller do
  let(:admin_user) { create(:spree_user,:with_super_admin_role, password: 'pass@123') }
  let(:admin_store) {create(:spree_store,url: 'example.com')}

  let(:store_admin) { create(:spree_user,:with_store_admin_role,password: 'pass@123') }
  let(:reseller_store){create(:spree_store,url: 'reseller1.example.com',admin_email: store_admin.email)}
  

  before(:each) { @routes = Spree::Core::Engine.routes }
  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }
  
  
  context "Admin store [exapmple.com]" do
    before(:each) do
      @request.host = admin_store.url #exapmple.com
    end

    context "Valid Registration details" do
      context "and html format is used" do
        it "redirect if success" do


          store_admin_email = "reseller1@exapmple.com"# 
         
          post :create, params: { spree_user: { business_name: "store01", subdomain: "store01",email: store_admin_email,password: "pass@123",password_confirmation: "pass@123",
            reseller_signup: true }}
         
          #Signed up flash message should be displayed on successfully signing up
           expect(flash[:success]).to eq(Spree.t(:send_instructions))
          

          store_admin = Spree::User.find_by_email(store_admin_email)

          #New user on admin store must have admin tenat id
          expect(store_admin.account_id).to eq(TenantManager::TenantHelper.admin_tenant_id)

          #New user must be store admin
          expect(store_admin.store_admin?).to eq(true)

          #expect a new Spree Store is created

        end
      end
    end
  end


  context "Reseller store [reseller1.exapmple.com]" do

    before(:each) do
      @request.host = reseller_store.url #reseller1.exapmple.com.me
    end

    context "Valid Registration details" do
      context "and html format is used" do
        it "redirect if success" do
          customer_email = Faker::Internet.unique.email

          post :create, params: { spree_user: {email: customer_email,password: "opspi@123",password_confirmation: "opspi@123" }}

           #Signed up flash message should be displayed on successfully signing up
          expect(flash[:success]).to eq(Spree.t(:send_instructions))

          customer = Spree::User.find_by_email(customer_email)

          #New user on admin store must have admin tenat id
          expect(customer.account_id).to eq(reseller_store.account_id)

        end

      end
    end

  end
end

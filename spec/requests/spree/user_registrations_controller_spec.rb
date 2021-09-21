require 'rails_helper'

RSpec.describe Spree::UserRegistrationsController, type: :controller do
  let(:admin_user) { create(:spree_user,:with_super_admin_role,password: 'opspi@123') }
  let(:admin_store) {create(:spree_store,url: 'exapmple.com')}
  

  before(:each) { @routes = Spree::Core::Engine.routes }
  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }
  
  
    context "Admin store [exapmple.com]" do
      before(:each) do
        @request.host = admin_store.url #exapmple.com
      end

      context "Valid Registration details" do
        context "and html format is used" do
          it "redirect if success" do
            store_admin_email = "reseller1@exapmple.com"#Faker::Internet.unique.email 
           
            post :create, params: { spree_user: { business_name: "store01", subdomain: "store01",email: store_admin_email,password: "opspi@123",password_confirmation: "opspi@123",reseller_signup: true }}
            
            
            #Signed up flash message should be displayed on successfully signing up
            expect(flash[:notice]).to eq(I18n.t('devise.user_registrations.signed_up'))
            

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

     end

end

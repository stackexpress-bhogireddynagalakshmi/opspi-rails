require 'rails_helper'

RSpec.describe Spree::UserSessionsController, type: :controller do
  let(:admin_user) { create(:spree_user,:with_super_admin_role,password: 'opspi@123') }
  let(:admin_store) {create(:spree_store,url: 'exapmple.com')}
  
  let(:store_admin) { create(:spree_user,:with_store_admin_role,password: 'opspi@123') }
  let(:store_admin2) { create(:spree_user,:with_store_admin_role,password: 'opspi@123') }

  let(:reseller_store){create(:spree_store,url: 'reseller1.exapmple.com.me',admin_email: store_admin.email)}
  let(:reseller_store2){create(:spree_store,url: 'reseller2.exapmple.com.me',admin_email: store_admin2.email)}

  before(:each) { @routes = Spree::Core::Engine.routes }
  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }
  
  
    context "store [exapmple.com.me]" do
      before(:each) do
        @request.host = admin_store.url #exapmple.com.me
      end

      context "using incorrect login information on admin store" do
        context "and html format is used" do
          it "renders new template again with errors" do
            post :create, params: { spree_user: { email: admin_user.email, password: 'wrongPass123' }}
            expect(flash[:error]).to eq(I18n.t('devise.failure.invalid'))
          end
        end
      end

      context '#create session for super admin' do
        it 'using correct login information on admin store' do
          post :create, params: { spree_user: { email: admin_user.email ,password: 'opspi@123'} }
          expect(flash[:error]).to eq(nil)
          expect(flash[:success]).to eq("Logged in successfully")
        end
      end

      context '#create session for store_admin' do
        it 'using correct login information on admin store' do
          post :create, params: { spree_user: { email: store_admin.email ,password: 'opspi@123'} }
          
          expect(flash[:error]).to eq(nil)
          expect(flash[:success]).to eq("Logged in successfully")
        end
      end

    end

     context "store [reseller1.exapmple.com.me]" do

      before(:each) do
        @request.host = reseller_store.url #reseller1.exapmple.com.me
      end

       context "#create" do
        context "and html format is used" do
          it "store admin of another store can not login to different store" do
            post :create, params: { spree_user: { email: store_admin2.email, password: 'opspi@123' }}
            expect(flash[:alert]).to eq("Invalid Username or Password") # check userDecorator devise active for authentication
          end

          # it "store admin can login to thier store only" do
          #   post :create, params: { spree_user: { email: store_admin.email, password: 'opspi@123' }}
          #   byebug
          #   expect(flash[:error]).to eq(nil) # check userDecorator devise active for authentication
          #   expect(flash[:success]).to eq("Logged in successfully")
          # end
          
        end
      end




     end

end

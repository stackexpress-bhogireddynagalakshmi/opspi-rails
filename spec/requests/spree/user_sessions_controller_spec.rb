require 'rails_helper'

RSpec.describe Spree::UserSessionsController, type: :controller do
  let(:admin_user) { create(:spree_user,password: 'opspi@123') }
  let(:admin_store) {create(:spree_store)}
  before(:each) { @routes = Spree::Core::Engine.routes }
  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }
  
  before(:each) do
    @request.host = admin_store.url
  end

  context '#create' do
    it 'using correct login information' do
      post :create, params: { user: { email: admin_user.email ,password: 'password'} }
      expect(flash[:error]).to eq(nil)
      #expect(response).to 
    end
  end

  context "using incorrect login information" do
    context "and html format is used" do
      it "renders new template again with errors" do
        post :create, params: { spree_user: { email: admin_user.email, password: 'wrongPass' }}
        # expect(response).to render_template('new')
        # expect(flash[:error]).to eq I18n.t(:'devise.failure.invalid')
      end
    end
  end

end

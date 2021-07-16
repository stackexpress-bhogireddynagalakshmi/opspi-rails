require 'rails_helper'


RSpec.describe Spree::UsersController, type: :controller do
  let(:admin_user) { create(:spree_user) }
  let(:admin_store) {create(:spree_store)}
  before(:each) { @routes = Spree::Core::Engine.routes }
  

  before(:each) do
    @request.host = admin_store.url
  end

  before { allow(controller).to receive(:spree_current_user) { user } }


  context '#load_object' do
    it 'redirects to signup path if user is not found' do
      allow(controller).to receive(:spree_current_user) { nil }
      put :update, params: { user: { email: 'foobar@example.com' } }
      expect(response).to redirect_to login_path
    end
  end

end


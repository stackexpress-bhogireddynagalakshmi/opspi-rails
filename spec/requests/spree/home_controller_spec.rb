require 'rails_helper'


RSpec.describe Spree::HomeController, type: :controller do
  let(:admin_user) { create(:spree_user) }
  let(:admin_store) {create(:spree_store)}
  before(:each) { @routes = Spree::Core::Engine.routes }
  
  context  "vising the store url which does not exits" do
    it 'should show error message' do  
      get :index
      expect(response.body).to eq("Sorry, this domain is currently unavailable.")
    end
  end


  context "vising admin store" do
    before(:each) do
      @request.host = admin_store.url
    end

    it "should allow reseller to see landing page" do
      get :index
      expect(response.status).to eq(200)
    end
    
  end

end


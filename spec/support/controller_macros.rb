module ControllerMacros

 def login_user
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    let!(:user) { create(:spree_user) }

    sign_in user
  end
  
 end
end
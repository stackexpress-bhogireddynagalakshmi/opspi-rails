module ControllerMacros

  def login_super_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryBot.create(:spree_user,:with_super_admin_role,email: 'opspi@example.com',account_id: 1,password: 'opspi@123') # Using factory bot as an example
    end
  end

 def login_user
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    let!(:user) { create(:spree_user) }

    sign_in user
  end
  
 end
end
class IspConfigProvisioningJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = Spree::User.find(user_id)  
    if user.store_admin? # reseller
    	provision_store_admin_account(user)
    else
    	provision_user_account(user)
    end if user.account&.isp_config_access?
    
  end


  private

  def provision_store_admin_account(user)
  	response  = user.isp_config.create
  	unless response[:success] == true   raise StandardError.new response[:message]
  end

   def provision_user_account(user)
   	 response = user.isp_config.create  
   	 unless response[:success] == true  raise StandardError.new response[:message]
  end

end

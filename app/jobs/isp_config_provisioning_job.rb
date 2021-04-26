class IspConfigProvisioningJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    if user.account.isp_config_access?
      if user.store_admin? # reseller
      	provision_store_admin_account(user)
      else
      	provision_user_account(user)
      end
    end
  end


  private

  def provision_store_admin_account(user)
  	 response  = user.isp_config.create
  	 if response[:success] == true
  	 	

  	 else
  	 	raise StandardError.new response[:message]
  	 end
  end

   def provision_user_account(user)
   	 response = suser.isp_config.create  

   	 if response[:success] == true

  	 else
  	 	raise StandardError.new response[:message]
  	 end	
  end

end

module AppManager
	class AccountProvisioner
    
		attr_reader :user,:product,:order

		  def initialize(user,options = {})
  			@user = user
  			@product = options[:product]
        @order = options[:order]
  		end

  		def call
  		#	if TenantManager::TenantHelper.current_admin_tenant?
          provison_solid_cp_account
          provision_isp_config_account
#        end
  		end


      def provison_solid_cp_account
        return unless TenantManager::TenantHelper.unscoped_query{user.account&.solid_cp_access?}
        
        SolidCpProvisioningJob.set(wait: 3.second).perform_later(user.id,product&.id) 
      end

      def provision_isp_config_account
        return unless TenantManager::TenantHelper.unscoped_query{user.account&.isp_config_access?}

        IspConfigProvisioningJob.set(wait: 3.second).perform_later(user.id,product&.id)
      end

	end
end
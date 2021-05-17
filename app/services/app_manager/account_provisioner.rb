module AppManager
	class AccountProvisioner
		attr_reader :user,:product

		def initialize(user,options = {})
  			@user = user
  			@product = options[:product]
  		end

  		def call
  			return unless TenantManager::TenantHelper.current_admin_tenant?

  			SolidCpProvisioningJob.set(wait: 3.second).perform_later(user.id,product&.id) if TenantManager::TenantHelper.unscoped_query{user.account&.solid_cp_access?}
  			
  			IspConfigProvisioningJob.set(wait: 3.second).perform_later(user.id) if TenantManager::TenantHelper.unscoped_query{user.account&.isp_config_access?}
  		end
	end
end
module TenantManager
  class UserTenantUpdater < ApplicationService
		attr_reader :user,:tenant_id
		
		def initialize(user,tenant_id)
			@user = user
     	@tenant_id = tenant_id
		end

		def call
			if user.reseller_signup && TenantManager::TenantHelper.current_admin_tenant?
				ActsAsTenant.without_tenant do
          user.update_column :account_id, tenant_id
			  end
			end
		end
 	end
end
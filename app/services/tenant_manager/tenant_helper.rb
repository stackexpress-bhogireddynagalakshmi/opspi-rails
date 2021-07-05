module TenantManager
	class TenantHelper
		def self.current_admin_tenant?
			ActsAsTenant.current_tenant&.domain == ENV['ADMIN_DOMAIN']
		end

		#current tenant based on URL of the store
		def self.current_tenant
			ActsAsTenant.current_tenant
		end

		def self.current_tenant_id
			ActsAsTenant.current_tenant&.id
		end

		def self.admin_tenant
			Account.where(domain: ENV['ADMIN_DOMAIN']).first
		end
		
		def self.admin_tenant_id
			Account.where(domain: ENV['ADMIN_DOMAIN']).first&.id
		end

		def self.unscoped_query(&block)
    	ActsAsTenant.without_tenant do 
    	  yield 
    	end
		end

	end
end

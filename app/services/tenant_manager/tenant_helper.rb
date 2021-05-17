module TenantManager
	class TenantHelper

		def self.current_admin_tenant?
			ActsAsTenant.current_tenant&.id == 1
			 # ActsAsTenant.current_tenant.blank?
		end

		def self.current_tenant
			ActsAsTenant.current_tenant
		end

		def self.unscoped_query(&block)
	      	ActsAsTenant.without_tenant do 
	      	  	yield 
	      	end
		end

	end
end
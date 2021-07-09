module TenantManager
  class ProductTenantUpdater < ApplicationService
		attr_reader :product,:tenant_id
		
		def initialize(product,tenant_id=nil)
			@product = product
      		@tenant_id = tenant_id
		end

		def call
			ActsAsTenant.without_tenant do
        	product.update_column :account_id, tenant_id
		  end
    	end 
 	end
end


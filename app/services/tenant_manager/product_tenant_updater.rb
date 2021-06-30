module TenantManager
  class ProductTenantUpdater < ApplicationService
<<<<<<< HEAD
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
    
=======
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
>>>>>>> c9edcc25c01a60f80fbc6a108ca1b684916a62fa
 	end
end
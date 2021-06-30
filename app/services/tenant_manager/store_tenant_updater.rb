module TenantManager
  class StoreTenantUpdater < ApplicationService
<<<<<<< HEAD
  	attr_reader :store,:tenant_id
  		
		def initialize(store,tenant_id=nil)
			@store = store
      @tenant_id = tenant_id
		end

		def call
			ActsAsTenant.without_tenant do
        store.update_column :account_id, tenant_id
		  end
    end
    
=======
  		attr_reader :store,:tenant_id
  		
  		def initialize(store,tenant_id=nil)
  			@store = store
        @tenant_id = tenant_id
  		end

  		def call
  			 ActsAsTenant.without_tenant do
           store.update_column :account_id, tenant_id
			   end
      end
>>>>>>> c9edcc25c01a60f80fbc6a108ca1b684916a62fa
 	end
end
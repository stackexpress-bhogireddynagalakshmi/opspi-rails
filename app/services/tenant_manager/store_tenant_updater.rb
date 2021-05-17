module TenantManager
  class StoreTenantUpdater < ApplicationService
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
 	end
end
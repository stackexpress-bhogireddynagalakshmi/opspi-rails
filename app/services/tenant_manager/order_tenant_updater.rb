module TenantManager
  class OrderTenantUpdater < ApplicationService
  		attr_reader :order,:tenant_id
  		
  		def initialize(order,tanent_id=nil)
  			@order = order
        @tanent_id = tanent_id
  		end

  		def call

        if TenantManager::TenantHelper.current_admin_tenant?

      	 ActsAsTenant.without_tenant do  
             if order.user_id.blank? 
              order.update_column :account_id, nil  
             else
               order.update_column :account_id, order.user&.account_id
             end
         end

       end

      end

 	end
end
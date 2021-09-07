module TenantManager
  class OrderTenantUpdater < ApplicationService
  		attr_reader :order,:tenant_id
  		
  		def initialize(order,tanent_id=nil)
  			@order = order
        @tanent_id = tanent_id
  		end

  		def call
        return unless  TenantManager::TenantHelper.current_admin_tenant?
       
      	 ActsAsTenant.without_tenant do  
           if order.user_id.blank? 
            order.update_column :account_id, nil  
           else
             order.update_column :account_id, order.user&.account_id
           end
        end
      end


      # Oder is tenanted model so account is is automatically set based on the current store 
      # Scenario When reseller is creating an order from his own store so this order needs to be shown 
      # on super admin store and to do that we have to set the super admin store tenant id to order table

      def update_tenant_id_to_order
        ActsAsTenant.without_tenant do  
           order.update_column :account_id, tenant_id
        end
      end
 	end
end
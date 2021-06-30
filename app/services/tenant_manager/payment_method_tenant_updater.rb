
module TenantManager
  class PaymentMethodTenantUpdater < ApplicationService
		attr_reader :payment_method,:tenant_id
		
		def initialize(payment_method,tenant_id=nil)
			@payment_method = payment_method
      		@tenant_id = tenant_id
		end

		def call
			ActsAsTenant.without_tenant do
        payment_method.update_column :account_id, tenant_id
		  end
    end 
 	end
end
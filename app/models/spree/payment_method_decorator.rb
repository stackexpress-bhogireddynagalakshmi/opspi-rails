module Spree
	module PaymentMethodDecorator

		def self.prepended(base)
	    base.acts_as_tenant :account,:class_name=>'::Account'
	    base.after_commit :add_to_tenant, on: [:create,:update]
	  end

	  def add_to_tenant
  		if ActiveRecord::Base.connection.column_exists?(:spree_payment_methods, :account_id) && self.account_id.blank?
  			TenantManager::PaymentMethodTenantUpdater.new(self,1).call
  		end
	 	end
	 	
	end
end

::Spree::PaymentMethod.prepend Spree::PaymentMethodDecorator if ::Spree::Address.included_modules.exclude?(Spree::PaymentMethodDecorator)



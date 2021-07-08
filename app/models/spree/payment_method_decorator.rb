module Spree
	module PaymentMethodDecorator

		def self.prepended(base)
	    base.acts_as_tenant :account,:class_name=>'::Account'
	    base.after_commit :add_to_tenant, on: [:create,:update]
      base.after_commit :update_store_payment_methods, on: [:create,:update]
	  end

	  def add_to_tenant
  		if ActiveRecord::Base.connection.column_exists?(:spree_payment_methods, :account_id) && self.account_id.blank?
  			TenantManager::PaymentMethodTenantUpdater.new(self,1).call
  		end
	 	end

    def update_store_payment_methods
      current_store = TenantManager::TenantHelper.current_tenant.spree_store
      self.stores << current_store  unless self.stores.include?(current_store)
    end
	 	
	end
end

::Spree::PaymentMethod.prepend Spree::PaymentMethodDecorator if ::Spree::Address.included_modules.exclude?(Spree::PaymentMethodDecorator)



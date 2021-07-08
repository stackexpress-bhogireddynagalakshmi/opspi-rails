module Spree
	module OrderDecorator

		def self.prepended(base)
	    	base.acts_as_tenant :account
	    	
	    	base.checkout_flow do
			    go_to_state :address
			    go_to_state :payment, :if => lambda { |order| order.payment_required? }
			    go_to_state :confirm, :if => lambda { |order| order.confirmation_required? }
			    go_to_state :complete
			end
		end

	  def create_subscriptions(payment)
  		line_items.each do |line_item|
        if line_item.product.subscribable?
          Subscription.subscribe!(
           user: self.user,
           product: line_item.product,
           order: self	            
          )
        end
    	end
	  end

	  def valid_plan_subscription?
	  		product = subscribable_product
	 		if product && self.user.susbscriptions.joins(:plan).active.pluck(:server_type).include?(product.server_type) && (payments.blank? ||  !payments.last.completed?)
	 		 	errors.add(:base, "Your are already subscribed to one #{product.server_type.titleize} Plan. Please check My Subscriptions page for more details")
	 		 	return false
	 		end
	  end

	  def finalize!
  		super
  		update_tenant_if_needed
  		provision_accounts
	  end

	  def update_tenant_if_needed
  		TenantManager::TenantServiceExecutor.new(TenantManager::TenantHelper.unscoped_query{self.user}).call

  		TenantManager::TenantUpdater.new(TenantManager::TenantHelper.unscoped_query{self.user.reload.account},order: self,product: subscribable_product).setup_panels_access
	  end

  	def provision_accounts
  		AppManager::AccountProvisioner.new(TenantManager::TenantHelper.unscoped_query{self.user},order: self).call
  	end

  	def subscribable_products
  		self.products.where(subscribable: true)
  	end
  	
  	def subscribable_product
  		subscribable_products.first
  	end
	end
end

Spree::Order.state_machine.before_transition to: :payment, do: :valid_plan_subscription?
::Spree::Order.prepend Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(Spree::OrderDecorator)

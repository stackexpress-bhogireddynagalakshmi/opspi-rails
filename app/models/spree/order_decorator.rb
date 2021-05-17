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

	  	def update_tenant_if_needed
	  		TenantManager::TenantServiceExecutor.new(self.user).call
	  		TenantManager::TenantUpdater.new(TenantManager::TenantHelper.unscoped_query{self.user.account},order: self,product: subscribable_product).setup_panels_access
	  	end

	  	def provision_accounts
	  		AppManager::AccountProvisioner.new(TenantManager::TenantHelper.unscoped_query{self.user}).call
	  	end


	  	private

	  	def subscribable_product
	  		self.products.select{|x|x.subscribable}.first
	  	end

	end
end

Spree::Order.state_machine.before_transition to: :payment, do: :valid_plan_subscription?
Spree::Order.state_machine.after_transition to: :complete, do: :update_tenant_if_needed
Spree::Order.state_machine.after_transition to: :complete, do: :provision_accounts	

::Spree::Order.prepend Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(Spree::OrderDecorator)

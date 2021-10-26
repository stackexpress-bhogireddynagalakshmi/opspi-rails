module Spree
	module OrderDecorator

		def self.prepended(base)
	    	base.acts_as_tenant :account
        #base.belongs_to :account

        # base.belongs_to :bill_address, foreign_key: :bill_address_id, class_name: 'Spree::Address',
        #                       optional: true,dependent: :delete

        # base.belongs_to :ship_address, foreign_key: :ship_address_id, class_name: 'Spree::Address',
        #                       optional: true, dependent: :delete


        base.after_create_commit :update_tenant_id
	    	base.checkout_flow do
			    go_to_state :address
			    go_to_state :payment, :if => lambda { |order| order.payment_required? }
			    go_to_state :confirm, :if => lambda { |order| order.confirmation_required? }
			    go_to_state :complete
			end

      base.enum order_type: {
        manual: 0, # User is creating order by himself
        auto: 1 # Order created against invoice by cron
      }
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
      invoice = CustomInvoiceFinder.new(order_id: self.id).unscoped_execute
      return if invoice

	  	product = subscribable_product
	 		if product && self.user.subscriptions.joins(:plan).active.pluck(:server_type).include?(product.server_type) && (payments.blank? ||  !payments.last.completed?)
	 		 	errors.add(:base, "Your are already subscribed to one #{product.server_type.titleize} Plan. Please check My Subscriptions page for more details")
	 		 	return false
	 		end
	  end

	  def finalize!
  		super
      invoice = CustomInvoiceFinder.new(order_id: self.id).unscoped_execute

      if invoice.present?
        if not_a_check_payment?
          invoice.close!
          invoice.save
        else
          invoice.process!
          invoice.save
        end
      end
    
      tenant_service = TenantService.find_by({user_id: TenantManager::TenantHelper.unscoped_query{self.user.id}})

      if invoice.blank? || (tenant_service.present? && !tenant_service.service_executed?)
        update_tenant_if_needed
        provision_accounts
      end

      #InvoiceMailer.send_notification(invoice)
	  end

	  def update_tenant_if_needed
      Rails.logger.info { "Updated Tenant if needed called " }

  		TenantManager::TenantServiceExecutor.new(
        TenantManager::TenantHelper.unscoped_query{self.user}
      ).call

  		TenantManager::TenantUpdater.new(
        TenantManager::TenantHelper.unscoped_query{self.user.reload.account},order: self,product: subscribable_product
      ).call
	  end

  	def provision_accounts
  		AppManager::AccountProvisioner.new(
        TenantManager::TenantHelper.unscoped_query{self.user},order: self
      ).call
  	end

  	def subscribable_products
  		self.products.where(subscribable: true)
  	end
  	
  	def subscribable_product
  		subscribable_products.first
  	end

    def update_tenant_id
      return unless self.user



      tenant_id =
      if self.user.store_admin?
        TenantManager::TenantHelper.admin_tenant.id
      else
        self.user.account_id
      end
      Rails.logger.info {"update_tenant_id: #{tenant_id}"}


      TenantManager::OrderTenantUpdater.new(self,tenant_id).update_tenant_id_to_order
    end

    def not_a_check_payment?
      self.payments.last.check_number.blank?
    end
	end
end

Spree::Order.state_machine.before_transition to: :payment, do: :valid_plan_subscription?
::Spree::Order.prepend Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(Spree::OrderDecorator)

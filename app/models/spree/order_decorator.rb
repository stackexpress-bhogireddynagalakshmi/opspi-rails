# frozen_string_literal: true

module Spree
  module OrderDecorator
    def self.prepended(base)
      base.acts_as_tenant :account

      base.after_create_commit :update_tenant_id
      base.checkout_flow do
        go_to_state :address
        go_to_state :payment, if: ->(order) { order.payment_required? }
        go_to_state :confirm, if: ->(order) { order.confirmation_required? }
        go_to_state :complete
      end

      base.enum order_type: {
        manual: 0, # User is creating order by himself
        auto: 1 # Order created against invoice by cron
      }
    end

    def create_subscriptions(_payment)
      line_items.each do |line_item|
        next unless line_item.product.subscribable?

        Subscription.subscribe!(
          user: user,
          product: line_item.product,
          variant: line_item.variant,
          order: self
        )
      end
    end

    def valid_plan_subscription?
      invoice = CustomInvoiceFinder.new(order_id: id).unscoped_execute
      return if invoice

      product = subscribable_product
      if product && user.present? && user.subscriptions.joins(:plan).active.pluck(:server_type).include?(product.server_type) && (payments.blank? || !payments.last.completed?)
        errors.add(:base,
                   "Your are already subscribed to one #{product.server_type.titleize} Plan. Please check My Subscriptions page for more details")

        false
      end
    end

    def finalize!
      super
      invoice = CustomInvoiceFinder.new(order_id: id).unscoped_execute

      if invoice.present?
        if not_a_check_payment?
          invoice.close!
        else
          invoice.process!
        end
        invoice.save
      end

      update_tenant_if_needed

      domain_registration
    end

    def update_tenant_if_needed
      Rails.logger.info { "Updated Tenant if needed called " }

      # tenantService object exist and not already executed
      TenantManager::TenantServiceExecutor.new(
        TenantManager::TenantHelper.unscoped_query { user }
      ).call

      # solid_cp_access or isp_config_access fields are updated based on the product purchased
      TenantManager::TenantUpdater.new(
        TenantManager::TenantHelper.unscoped_query { user.reload.account }, order: self
      ).call
    end

    def domain_registration
      line_items.each do |line_item|
        next unless line_item.product.domain?

        DomainRegistrationJob.set(wait: 3.second).perform_later(line_item)
      end
    end

    def subscribable_products
      products.where(subscribable: true)
    end

    def subscribable_product
      subscribable_products.first
    end

    def update_tenant_id
      return unless user

      tenant_id =
        if user.store_admin?
          TenantManager::TenantHelper.admin_tenant.id
        else
          user.account_id
        end
      Rails.logger.info { "update_tenant_id: #{tenant_id}" }

      TenantManager::OrderTenantUpdater.new(self, tenant_id).update_tenant_id_to_order
    end

    def not_a_check_payment?
      payments.last.check_number.blank?
    end

    def panels_access(panel)
      @panels = []
      if self.present?
        self.line_items.each do |line_item|
          next if line_item.product.blank?

          if line_item.product.windows?
            panel_name = 'solid_cp'
          elsif line_item.product.linux?
            panel_name = 'isp_config'
          elsif line_item.product.reseller_plan?
            panel_name = 'reseller_plan'
          end
              
          @panels << panel_name unless @panels.include?(panel)
        end
      end
      @panels.include?(panel)
    end
  end
end

Spree::Order.state_machine.before_transition to: :payment, do: :valid_plan_subscription?
::Spree::Order.prepend Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(Spree::OrderDecorator)

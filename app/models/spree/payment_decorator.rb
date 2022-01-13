module Spree
  module PaymentDecorator

    def self.prepended(base)
      base.state_machine initial: :checkout do
          after_transition to: :completed, do: [:create_subscriptions!,:update_invoice_status]
       end

      base.validates :check_number,uniqueness: true, if: -> { check_number.present? }
    end
      
    #Issue in State machine
    def create_subscriptions!
      invoice = CustomInvoiceFinder.new(order_id: self.order.id).unscoped_execute

      return if invoice # if Invoice Payment then no need to create subscription again

      self.order.create_subscriptions(self)
    end


    def update_invoice_status
      invoice = CustomInvoiceFinder.new(order_id: self.order.id).unscoped_execute

      return unless invoice

      unless TenantManager::TenantHelper.unscoped_query{ invoice.order.not_a_check_payment? }
        invoice.close!
        invoice.save
      end

    end
  end
end

::Spree::Payment.prepend Spree::PaymentDecorator if ::Spree::Order.included_modules.exclude?(Spree::PaymentDecorator)
Spree::PermittedAttributes.payment_attributes.push << :check_number

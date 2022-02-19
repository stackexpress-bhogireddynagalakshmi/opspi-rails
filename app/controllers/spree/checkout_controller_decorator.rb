# frozen_string_literal: true

module Spree
  module CheckoutControllerDecorator
    # Updates the order and advances to the next state (when possible.)
    def update
      update_payments_methods_attributes_params
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        update_order_store_id

        @order.temporary_address = !params[:save_user_address]

        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(spree.checkout_state_path(@order.state)) && return
        end

        if @order.completed?
          @current_order = nil
          flash['order_completed'] = true
          redirect_to completion_route
        else
          redirect_to spree.checkout_state_path(@order.state, invoice_number: params[:invoice_number])
        end
      else
        render :edit
      end
    rescue Exception => e
      puts e.backtrace
      raise
    end

    def load_order_with_lock
      if params[:invoice_number].present?
        invoice = CustomInvoiceFinder.new(invoice_number: params[:invoice_number]).unscoped_execute
        super unless invoice
        super if invoice.closed?

        TenantManager::TenantHelper.unscoped_query do
          @order = InvoiceManager::OrderCreator.new(invoice).call
          cookies.signed[:token] = @order.token
        end

      else
        super
      end
    end

    def ensure_sufficient_stock_lines
      TenantManager::TenantHelper.unscoped_query { super }
    end

    def ensure_valid_state
      if @order.state != correct_state && !skip_state_validation?
        flash.keep
        @order.update_column(:state, correct_state)
        redirect_to spree.checkout_state_path(@order.state, invoice_number: params[:invoice_number])
      end
    end

    def ensure_valid_state_lock_version
      if params[:order] && params[:order][:state_lock_version]
        changes = @order.changes if @order.changed?
        @order.reload.with_lock do
          unless @order.state_lock_version == params[:order].delete(:state_lock_version).to_i
            flash[:error] = Spree.t(:order_already_updated)
            redirect_to(checkout_state_path(@order.state, invoice_number: params[:invoice_number])) && return
          end
          @order.increment!(:state_lock_version)
        end
        @order.assign_attributes(changes) if changes
      end
    end

    def set_state_if_present
      if params[:state]
        if @order.can_go_to_state?(params[:state]) && !skip_state_validation?
          redirect_to spree.checkout_state_path(@order.state,
                                                invoice_number: params[:invoice_number])
        end
        @order.state = params[:state]
      end
    end

    def check_authorization
      # authorize!(:edit, current_order, cookies.signed[:token])
    end

    def update_payments_methods_attributes_params
      return unless params[:order].present?
      return unless params[:order][:payments_attributes].present?

      params[:order][:payments_attributes].each(&:permit!)

      params[:order][:payments_attributes].each_with_index do |pa, idx|
        next if idx.zero?

        params[:order][:payments_attributes][0].merge!(pa)
        # TODO: If Store has two check payment methods and if user fills check number in first check payment and then selects different check payment method and enter another check no so here merge might not be able to decide which check no is correct. Need to either restrict one check payment per store or some thing to prevent this issue
      end
      params[:order][:payments_attributes] = [params[:order][:payments_attributes][0]]
    end

    def update_order_store_id
      if current_spree_user.present?
        store_id = if current_spree_user.store_admin?
                     TenantManager::TenantHelper.admin_tenant.spree_store.id
                   else
                     current_store.id
                   end
        @order.update_column(:store_id, store_id)
      end
    end
  end
end

if ::Spree::OrdersController.included_modules.exclude?(Spree::CheckoutControllerDecorator)
  ::Spree::CheckoutController.prepend Spree::CheckoutControllerDecorator
end

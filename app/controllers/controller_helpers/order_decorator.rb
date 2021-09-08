
module ControllerHelpers
    module OrderDecorator

     # #The current incomplete order from the token for use in cart and during checkout
     #  def current_order(options = {})
     #    options[:create_order_if_necessary] ||= false
     #    options[:includes] ||= true

     #    if @current_order
     #      @current_order.last_ip_address = ip_address
     #      return @current_order
     #    end

     #    if params[:invoice_number].present?
     #      invoice = current_invoice_finder.new(scope: Invoice, invoice_number: params[:invoice_number]).execute
     #       if invoice
     #          @current_order =  TenantManager::TenantHelper.unscoped_query{invoice.order}
              
     #          TenantManager::TenantHelper.unscoped_query{@current_order.update({last_ip_address: ip_address})}
     #       end
     #    else
     #      @current_order = find_order_by_token_or_user(options, true) 
     #    end


     #    if options[:create_order_if_necessary] && (@current_order.nil? || @current_order.completed?)
     #      @current_order = current_store.orders.create!(current_order_params)
     #      @current_order.associate_user! try_spree_current_user if try_spree_current_user
     #      @current_order.last_ip_address = ip_address
     #    end

     #    @current_order
     #  end

      def current_invoice_finder
        CustomInvoiceFinder
      end



        def find_order_by_token_or_user(options = {}, with_adjustments = false)
          order = super

          if order.nil? && spree_current_user.present?

            token_order_params = current_order_params.except(:user_id)

            order = TenantManager::TenantHelper.unscoped_query {spree_current_user.orders.incomplete.find_by_token(token_order_params[:token]) }
          end

          order
        end

        def current_order_params
            order_data = { currency: current_currency, token: cookies.signed[:token], user_id: try_spree_current_user.try(:id),store_id:  get_current_store_id}
            Rails.logger.info { "Order Params: #{order_data}"  }

          order_data
        end

        def get_current_store_id
            if current_store.present? 
              return current_store.id
            elsif TenantManager::TenantHelper.current_tenant.present?
                    TenantManager::TenantHelper.current_tenant.spree_store.id
            else
                 Rails.logger.info { "Store Not found setting Store ID: as 1"  }
                1
            end
        end


    end
 end


::Spree::Core::ControllerHelpers::Order.prepend ::ControllerHelpers::OrderDecorator if ::Spree::Core::ControllerHelpers::Order.included_modules.exclude?(::ControllerHelpers::OrderDecorator)

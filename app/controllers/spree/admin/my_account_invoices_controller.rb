module Spree
    module Admin
class MyAccountInvoicesController < Spree::Admin::BaseController
    before_action :layout_type
    
    def index
        @invoices = TenantManager::TenantHelper.unscoped_query { current_spree_user.invoices.order(created_at: :desc) }
    end

    def layout_type
        if current_spree_user.store_admin?
            render layout: "spree/layouts/admin"
          elsif current_spree_user&.superadmin?
            render layout: "spree/layouts/admin"
          end
    end
end
end
end
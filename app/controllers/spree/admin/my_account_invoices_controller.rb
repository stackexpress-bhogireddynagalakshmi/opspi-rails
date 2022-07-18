module Spree
    module Admin
class MyAccountInvoicesController < Spree::Admin::BaseController
    def index
        @invoices = TenantManager::TenantHelper.unscoped_query { current_spree_user.invoices.order(created_at: :desc) }
    end
end
end
end
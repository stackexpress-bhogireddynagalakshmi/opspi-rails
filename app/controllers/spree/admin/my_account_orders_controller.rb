module Spree
    module Admin
class MyAccountOrdersController < Spree::Admin::BaseController
    def index
        # @orders = spree_current_user.orders
        @orders = TenantManager::TenantHelper.unscoped_query { current_spree_user.orders.order('created_at desc') }
    end
end
end
end

module Spree
    module Admin
class MyAccountOrdersController < Spree::Admin::BaseController
    def index
        @orders = spree_current_user.orders
    end
end
end
end

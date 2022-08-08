# frozen_string_literal: true

module Spree
  module Admin
    class DashboardController < Spree::Admin::BaseController
      def index 
        if current_spree_user.store_admin?
          render layout: "spree/layouts/admin"
        elsif current_spree_user&.superadmin?
          render layout: "spree/layouts/admin"
        else
          render layout: "dashkit_admin_layout"
        end
      end
    end
  end
end

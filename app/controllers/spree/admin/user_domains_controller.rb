module Spree
  module Admin
    class UserDomainsController < Spree::Admin::BaseController
      include ResourceLimitHelper
      # before_action :redirect_to_index, only: %i[new]

      def index
        @user_domains = current_spree_user.user_domains.order("created_at desc")
      end

      def new; end

      # def redirect_to_index
      #   unless domain_limit_exceed_check
      #     redirect_to admin_user_domains_path
      #   end
      # end
    end
  end
end

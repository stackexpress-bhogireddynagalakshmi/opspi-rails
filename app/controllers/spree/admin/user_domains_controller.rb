module Spree
  module Admin
    class UserDomainsController < Spree::Admin::BaseController
      def index
        @user_domains = current_spree_user.user_domains.order("created_at desc")
      end

      def new; end
    end
  end
end

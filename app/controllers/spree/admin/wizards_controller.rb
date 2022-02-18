module Spree
  module Admin
    class WizardsController < Spree::Admin::BaseController
      before_action :get_zone_list, only: :new

      def new; end


      def create
        binding.pry
        redirect_to admin_wizards_path
      end

      def index

      end

      private

      def get_zone_list
        response = current_spree_user.isp_config.hosted_zone.all_zones || []
        @hosted_zones  = response[:success] ? response[:response].response : []
      end

    end
  end
end

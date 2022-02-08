module Spree
  module Admin
     module Mail
      # Mail Domain controller
      class DomainsController < Spree::Admin::IspConfigResourcesController

        private
        def resource_id_field
          "isp_config_mail_domain_id"
        end

        def assoc
          "mail_domains"
        end

        def resource_params
          params.require("mail_domain").permit(:domain,:active)
        end

        def resource_index_path
          redirect_to admin_mail_domains_path
        end

        def isp_config_api
          current_spree_user.isp_config.mail_domain
        end
      end
    end
  end
end
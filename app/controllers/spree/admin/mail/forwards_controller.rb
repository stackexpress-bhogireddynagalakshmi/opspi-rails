# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Forwards controller
      class ForwardsController < Spree::Admin::IspConfigResourcesController
        before_action :get_current_user_mail_domains, only: %i[new edit create update]
        before_action :assemble_source_and_domain, only: %i[create update]

        private

        def resource_id_field
          "isp_config_mail_forward_id"
        end

        def assoc
          "mail_forwards"
        end

        def resource_params
          params.require("mail_forward").permit(:source, :destination, :type, :active, :allow_send_as, :greylisting)
        end

        def resource_index_path
          redirect_to admin_mail_forwards_path
        end

        def isp_config_api
          current_spree_user.isp_config.mail_forward
        end

        def get_current_user_mail_domains
          response = current_spree_user.isp_config.mail_domain.all
          @user_mail_domains = if response[:success]
                                 response[:response].response
                               else
                                 []
                               end
        end

        def assemble_source_and_domain
          params[:mail_forward][:source] = "#{params[:mail_forward][:source]}@#{params[:source_domain]}"
        end
      end
    end
  end
end

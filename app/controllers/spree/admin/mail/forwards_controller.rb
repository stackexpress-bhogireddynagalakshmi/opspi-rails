# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Forwards controller
      class ForwardsController <  Spree::Admin::BaseController
        include ResourceLimitHelper
        before_action :ensure_hosting_panel_access
        before_action :set_user_domain, only: [:new, :create, :update, :edit, :destroy]
        before_action :assemble_source_and_domain, only: %i[create update]
        before_action :set_mail_forward, only: %i[edit update destroy]

        def new
         @mail_forward = @user_domain.user_mail_forwards.build
        end

        def create 
          return @response = {success: false, message: I18n.t('spree.resource_limit_exceeds')} unless resource_limit_check(@user_domain.web_hosting_type,I18n.t('mail_forward'))  

          @response = isp_config_api.create(resource_params, user_domain: @user_domain)

          if @response[:success]
            @mail_forward = @user_domain.user_mail_forwards.where(source: resource_params[:source]).last 
          end
        end

        def update
          @response = isp_config_api.update(@mail_forward.id, resource_params)
          @mail_forward.reload
        end

        def destroy
          @response = isp_config_api.destroy(@mail_forward.id)
        end

        private

        # def resource_id_field
        #   "isp_config_mail_forward_id"
        # end

        # def assoc
        #   "mail_forwards"
        # end

        def resource_params
          params.require("mail_forward").permit(:source, :source_domain, :destination, :type, :active, :allow_send_as, :greylisting)
        end

        # def resource_index_path
        #   redirect_to request.referrer
        # end

        def isp_config_api
          current_spree_user.isp_config.mail_forward
        end

        def set_mail_forward
          @mail_forward = @user_domain.user_mail_forwards.find(params[:id])

          redirect_to admin_dashboard_path, notice: 'Not Authorized' if @mail_forward .blank?

        end

        # def get_current_user_mail_domains
        #   response = current_spree_user.isp_config.mail_domain.all
        #   @user_mail_domains = if response[:success]
        #                          response[:response].response
        #                        else
        #                          []
        #                        end
        # end

        def assemble_source_and_domain
          params[:mail_forward][:source] = "#{params[:mail_forward][:source]}@#{params[:mail_forward][:source_domain]}"
        end
      end
    end
  end
end

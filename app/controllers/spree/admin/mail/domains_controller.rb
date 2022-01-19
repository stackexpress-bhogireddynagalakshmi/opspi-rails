module Spree
  module Admin
     module Mail
      # Mail Domain controller
      class DomainsController < Spree::Admin::BaseController
        before_action :set_mail_domain, only: [:edit,:update,:destroy]

        def index
         response = mail_domain_api.all || []
          if response[:success]
            @domains  = response[:response].response
          else
            @domains = []
          end
        end

        def new; end

        def edit
          @response = mail_domain_api.find(@domain.isp_config_mail_domain_id)
          @mail_domain = @response[:response].response  if @response[:success].present?
        end

        def create
          @response  = mail_domain_api.create(mail_domain_params)
          set_flash
          redirect_to admin_mail_domains_path
        end

        def update
          @response  = mail_domain_api.update(@domain.isp_config_mail_domain_id, mail_domain_params)
          set_flash
          redirect_to admin_mail_domains_path
        end

        def destroy
          @response  = mail_domain_api.destroy(@domain.isp_config_mail_domain_id)
          set_flash
          redirect_to admin_mail_domains_path
        end

        private
        def set_flash
          if @response[:success] 
            flash[:success] = @response[:message]
          else
            flash[:error] = @response[:message] 
          end
        end

        def mail_domain_params
          params.require("mail_domain").permit(:domain,:active)
        end

        def mail_domain_api
          current_spree_user.isp_config.mail_domain
        end

        def set_mail_domain
          @domain = current_spree_user.mail_domains.find_by_isp_config_mail_domain_id(params[:id])

          redirect_to admin_mail_domains_path, notice: 'Not Authorized' if @domain.blank?
        end

      end
     end
  end
end
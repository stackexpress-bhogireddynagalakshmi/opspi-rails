# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Domain controller
      class DomainsController < Spree::Admin::IspConfigResourcesController
        before_action :get_zone_list, only: [:new, :edit]
        
        def create
          @response = current_spree_user.isp_config.mail_domain.create(resource_params)
          set_flash
          if @response[:success]
            resource_index_path
          else
            render :new
          end
        end

        def update
          super do
            active = params[:mail_domain][:active]
            dis = active == 'n' ? 'y' : 'n'
            if @response[:response].code == "ok"

              domain = params[:mail_domain][:domain]

              result = current_spree_user.isp_config.mail_user.all
              result[:response].response.each do |mail_user|
                next unless mail_user.email.include?(domain)

                current_spree_user.isp_config.mail_user.update(
                  mail_user.mailuser_id,
                  {
                    postfix:  active,
                    disablesmtp: dis,
                    disableimap: dis,
                    disablepop3: dis,
                    disabledeliver: dis,
                    greylisting: active
                  }
                )
              end
            end
          end
        end

        def destroy
          super do
            if @response[:response].code == "ok"

              domain = params[:mail_domian]

              result = current_spree_user.isp_config.mail_user.all
              result[:response].response.each do |mail_user|
                if mail_user.email.include?(domain)
                  current_spree_user.isp_config.mail_user.destroy(mail_user.mailuser_id)
                end
              end

            end
          end
        end

        private

        def set_flash
          if @response[:success]
            flash[:success] = @response[:message]
          else
            flash.now[:error] = @response[:message]
          end
        end

        def resource_id_field
          "isp_config_mail_domain_id"
        end

        def assoc
          "mail_domains"
        end

        def resource_params
          params.require("mail_domain").permit(:domain, :active)
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

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
            create_mx_response = create_mx_record
            resource_index_path
          else
            render :new
          end
        end

        def create_mx_record
          unless get_dns_domain_id.nil?
            mx_record_params = {}
            mx_record_params={
              type: "MX",
              name: resource_params[:domain],
              hosted_zone_name: nil,
	            priority: "10",
              ttl: "3600",
              hosted_zone_id: get_dns_domain_id,
              client_id: current_spree_user.isp_config_id
            }
            mailservers = [{mailserver: ENV['ISPCONFIG_MAIL_SERVER_01']},{mailserver: ENV['ISPCONFIG_MAIL_SERVER_02']}]
            mailservers.each do |mx|
              current_spree_user.isp_config.hosted_zone_record.create(mx_record_params.merge(mx))
            end   
          end       
        end

        def get_dns_domain_id
          dns_response  = current_spree_user.isp_config.hosted_zone.all_zones
          dns_domain_id = dns_response[:response].response.map{|x| x.id if x[:origin] == resource_params[:domain]+"."}
          dns_domain_id.compact.first
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

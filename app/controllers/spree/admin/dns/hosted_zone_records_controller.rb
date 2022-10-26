# frozen_string_literal: true

module Spree
  module Admin
    module Dns
      class HostedZoneRecordsController < Spree::Admin::BaseController
        before_action :ensure_hosting_panel_access
        before_action :set_hosted_zone
        before_action :set_user_domain, only: %i[create update destroy]

        def create
          @response = host_zone_record_api.create(host_zone_record_params)
          set_flash
          # redirect_to dns_admin_dns_hosted_zone_url(@hosted_zone.isp_config_host_zone_id)+"?dns_name=#{host_zone_record_params[:hosted_zone_name]}"
          # redirect_to "/admin/dns/hosted_zones/zone_overview?zone_name=#{host_zone_record_params[:hosted_zone_name]}&dns_id=#{@hosted_zone.isp_config_host_zone_id}&user_domain_id=#{host_zone_record_params[:user_domain_id]}"
          redirect_to request.referrer
        end

        def update
          @response = host_zone_record_api.update(host_zone_record_params)
          set_flash
          # redirect_to dns_admin_dns_hosted_zone_url(@hosted_zone.isp_config_host_zone_id)+"?dns_name=#{host_zone_record_params[:hosted_zone_name]}"
          # redirect_to "/admin/dns/hosted_zones/zone_overview?zone_name=#{host_zone_record_params[:hosted_zone_name]}&dns_id=#{@hosted_zone.isp_config_host_zone_id}"
          redirect_to request.referrer
        end

        def destroy
          res1 = host_zone_record_api.destroy(host_zone_record_params)

          res2 = website_api.destroy(@user_domain.user_website.id)

          # stepo 1 Delete Wev=bsite Domain
          # Step 2  Delete Mail Domain
          # Step 3 Delete FTP Users
          # step 4 Delete Database and Database users
          # Step Mail FOrwards/mailing list/spam filters/

          set_flash
          respond_to do |format|
            format.js { render inline: "location.reload();" }
            format.html { redirect_to request.referrer }
            # format.html { redirect_to  dns_admin_dns_hosted_zone_url(@hosted_zone.isp_config_host_zone_id)+"?dns_name=#{host_zone_record_params[:hosted_zone_name]}"}
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

        def host_zone_record_api
          current_spree_user.isp_config.hosted_zone_record
        end

        def website_api
          if @user_domain.linux?
            current_spree_user.isp_config.website
          else
            current_spree_user.solid_cp.web_domain
          end
        end

        def ftp_user_api
          if @user_domain.linux?
            current_spree_user.isp_config
                              .else
            current_spree_user.solid_cp.ftp_user
          end
        end

        def host_zone_record_params
          params.permit(:name, :type, :ipv4, :ipv6, :publickey, :dkim, :target, :mailserver, :priority, :nameserver, :content,
                        :hosted_zone_id, :ttl, :id, :client_id, :primary_id, :hosted_zone_name, :user_domain_id).merge!({ hosted_zone_id: @hosted_zone.isp_config_host_zone_id,
                                                                                                                          client_id: current_spree_user.isp_config_id })
        end

        def set_hosted_zone
          @hosted_zone = current_spree_user.hosted_zones.find_by_id(params[:hosted_zone_id])
        end
      end
    end
  end
end

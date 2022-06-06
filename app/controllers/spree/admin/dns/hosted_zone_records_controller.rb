# frozen_string_literal: true

module Spree
  module Admin
    module Dns
      class HostedZoneRecordsController < Spree::Admin::BaseController
        before_action :ensure_hosting_panel_access
        before_action :set_hosted_zone

        def create
          @response = host_zone_record_api.create(host_zone_record_params)
          set_flash
          redirect_to dns_admin_dns_hosted_zone_url(@hosted_zone.isp_config_host_zone_id)+"?dns_name=#{host_zone_record_params[:hosted_zone_name]}"
        end

        def update
          @response = host_zone_record_api.update(host_zone_record_params)
          set_flash
          redirect_to dns_admin_dns_hosted_zone_url(@hosted_zone.isp_config_host_zone_id)+"?dns_name=#{host_zone_record_params[:hosted_zone_name]}"
        end

        def destroy
          @response = host_zone_record_api.destroy(host_zone_record_params)
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
            flash[:error] = @response[:message]
          end
        end

        def host_zone_record_api
          current_spree_user.isp_config.hosted_zone_record
        end

        def host_zone_record_params
          params.permit(:name, :type, :ipv4, :ipv6, :publickey, :dkim, :target, :mailserver, :priority, :nameserver, :content,
                        :hosted_zone_id, :ttl, :id, :client_id, :primary_id, :hosted_zone_name).merge!({ hosted_zone_id: @hosted_zone.isp_config_host_zone_id,
                                                                                      client_id: current_spree_user.isp_config_id })
        end

        def set_hosted_zone
          @hosted_zone = current_spree_user.hosted_zones.find_by_id(params[:hosted_zone_id])
        end
      end
    end
  end
end

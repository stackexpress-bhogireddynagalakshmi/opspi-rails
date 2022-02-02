class Spree::Admin::HostedZoneRecordsController < Spree::Admin::BaseController
  before_action :set_hosted_zone
  require 'isp_config/hosted_zone_record'
    
    def create   
      @response =  IspConfig::HostedZoneRecord.new(host_zone_record_params).create
      set_flash
      redirect_to dns_admin_hosted_zone_url(@hosted_zone.isp_config_host_zone_id) 
    end

    def update
      @response = IspConfig::HostedZoneRecord.new(host_zone_record_params).update
      set_flash
      redirect_to dns_admin_hosted_zone_url(@hosted_zone.isp_config_host_zone_id) 
    end

    def destroy
      @response =  IspConfig::HostedZoneRecord.new(host_zone_record_params).destroy
      set_flash
      respond_to do |format|
        format.js {render inline: "location.reload();" }
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

    def host_zone_record_params
      params.permit(:name,:type,:ipv4,:ipv6,:publickey,:dkim,:target,:mailserver,:priority,:nameserver,:content,:hosted_zone_id,:ttl, :id, :client_id, :primary_id).merge!({hosted_zone_id: @hosted_zone.isp_config_host_zone_id,client_id: current_spree_user.isp_config_id})
    end

    def set_hosted_zone
      @hosted_zone = current_spree_user.hosted_zones.find_by_id(params[:hosted_zone_id])
    end

end

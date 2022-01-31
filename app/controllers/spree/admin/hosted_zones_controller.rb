class Spree::Admin::HostedZonesController < Spree::Admin::BaseController
  require 'isp_config/hosted_zone'
  before_action :set_zone_list, only: [:edit,:update,:destroy]
    def index
      @response = IspConfig::HostedZone.new(current_spree_user.isp_config).all_zones || []
      if @response[:success]
        @hosted_zones  = @response[:response].response
      else
        @hosted_zones = []
      end
    end

    def create
      @response = IspConfig::HostedZone.new(host_zone_params).create
      set_flash
      redirect_to admin_hosted_zones_path
    end

    def new; end

    def edit
      @response = IspConfig::HostedZone.new(@zone_list).get_zone
      @hosted_zone = @response[:response].response  if @response[:success].present?
    end

    def update
      @response  = IspConfig::HostedZone.new(host_zone_params).update(@zone_list.isp_config_host_zone_id)
      set_flash
      redirect_to admin_hosted_zones_path
    end

    def destroy
      @response  = IspConfig::HostedZone.new(@zone_list).destroy(@zone_list.isp_config_host_zone_id)
      set_flash
      redirect_to admin_hosted_zones_path
    end


    def dns
      @hosted_zone_record = HostedZoneRecord.new
      @hosted_zone = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:id])
      @hosted_zone_records_reponse = IspConfig::HostedZone.new(@hosted_zone).get_all_hosted_zone_records
      @hosted_zone_records = @hosted_zone_records_reponse[:response][:response]
    end

    private
    def set_flash
      if @response[:success] 
        flash[:success] = @response[:message]
      else
        flash[:error] = @response[:message] 
      end
    end

    def set_zone_list
      @zone_list = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:id])
    end

    def validate_params(dns_data)
        return {success: false,msg: I18n.t('isp_config.required_field_missing')} if dns_data[:name].blank? || dns_data[:status].blank?

        re = /(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]/
        return  dns_data[:name].match?(re) ?  {success: true} :  {success: false,msg: I18n.t('isp_config.invalid_zone_name')}

    end

    def host_zone_params
      params.require(:hosted_zones).permit(:name,:ns,:mbox,:refresh,:retry,:expire,:minimum,:ttl,:xfer,:also_notify,:update_acl,:isp_config_host_zone_id,:status,:hosted_zones,:commit).merge!({isp_config_id: current_spree_user.isp_config_id})
    end

end
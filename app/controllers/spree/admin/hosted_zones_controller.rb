class Spree::Admin::HostedZonesController < Spree::Admin::BaseController
  require 'isp_config/hosted_zone'
    def index
      @hosted_zones = current_spree_user.hosted_zones
    end

    def create
      response = validate_params(host_zone_params)
      if response[:success]
        result = HostedZone.create(host_zone_params)
      else 
        flash[:error] = response[:msg]
      end 
      redirect_to admin_hosted_zones_path
    end


    def dns
      @hosted_zone_record = HostedZoneRecord.new
      @hosted_zone = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:id])
      @hosted_zone_records_reponse = IspConfig::HostedZone.new(@hosted_zone).get_all_hosted_zone_records
      @hosted_zone_records = @hosted_zone_records_reponse[:response][:response]
    end

    private

    def validate_params(dns_data)
        return {success: false,msg: I18n.t('isp_config.required_field_missing')} if dns_data[:name].blank? || dns_data[:status].blank?

        re = /(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]/
        return  dns_data[:name].match?(re) ?  {success: true} :  {success: false,msg: I18n.t('isp_config.invalid_zone_name')}

    end

    def host_zone_params
      params.require(:hosted_zones).permit(:name,:isp_config_host_zone_id,:status).merge!({user_id: current_spree_user.id})
    end

end
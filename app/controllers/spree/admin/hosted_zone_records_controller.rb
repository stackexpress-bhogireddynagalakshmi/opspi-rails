class Spree::Admin::HostedZoneRecordsController < Spree::Admin::BaseController
  before_action :set_hosted_zone
  require 'isp_config/hosted_zone_record'
    
    def create   
      response = validate_params(host_zone_record_params)
      if response[:success]
      host_zone =  IspConfig::HostedZoneRecord.new(host_zone_record_params).create
        if host_zone[:success]
          flash[:success] = host_zone[:message]
        else
          flash[:error] = host_zone[:message]
        end
      else 
        flash[:error] = response[:msg]
      end 
      respond_with(host_zone) do |format|
        format.html { redirect_to dns_admin_hosted_zone_url(@hosted_zone.isp_config_host_zone_id) }
        format.js   { render layout: false }
      end  
    end

    def update
      response = validate_params(host_zone_record_params)
      if response[:success]
      host_zone = IspConfig::HostedZoneRecord.new(host_zone_record_params).update
        if host_zone[:success]
          flash[:success] = host_zone[:message]
        else
          flash[:error] = host_zone[:message]
        end
      else 
        flash[:error] = response[:msg]
      end        
      respond_with(host_zone) do |format|
        format.html { redirect_to dns_admin_hosted_zone_url(@hosted_zone.isp_config_host_zone_id) }
        format.js   { render layout: false }
      end  
    end

    def destroy
      host_zone =  IspConfig::HostedZoneRecord.new(host_zone_record_params).destroy
      if host_zone[:success]
        flash[:success] = host_zone[:message]
      else
        flash[:error] = host_zone[:message]
      end
      respond_to do |format|
        format.js {render inline: "location.reload();" }
      end
    end

    private

    def validate_params(r_data)
     
      if r_data[:type].eql?"A"

        return {success: false,msg: I18n.t('isp_config.required_field_missing')} if r_data[:type].blank? || r_data[:name].blank? || r_data[:ipv4].blank?

        re = IPV4_REGEX
        return  r_data[:ipv4].match?(re) ?  {success: true} :  {success: false,msg: "Invalid IPv4"}

      elsif r_data[:type].eql?"AAAA"

        return {success: false,msg: I18n.t('isp_config.required_field_missing')} if r_data[:type].blank? || r_data[:name].blank? || r_data[:ipv6].blank?

        re = IPV6_REGEX
        return r_data[:ipv6].match?(re) ?  {success: true} :  {success: false,msg: "Invalid IPv6"}
      
      elsif r_data[:type].eql?"CNAME"

        return {success: false,msg: I18n.t('isp_config.required_field_missing')} if r_data[:type].blank? || r_data[:name].blank? || r_data[:target].blank?

        re = DNS_ORIGIN_ZONE_REGEX
        return  r_data[:target].match?(re) ?  {success: true} :  {success: false,msg: "Invalid cname"}
      elsif r_data[:type].eql?"MX"

        return {success: false,msg: I18n.t('isp_config.required_field_missing')} if r_data[:type].blank? || r_data[:name].blank? || r_data[:mailserver].blank? || r_data[:priority].blank?

        re = DNS_ORIGIN_ZONE_REGEX
        return r_data[:mailserver].match?(re) ?  {success: true} :  {success: false,msg: "Invalid MX value"} 

      elsif r_data[:type].eql?"NS"

        return {success: false,msg: I18n.t('isp_config.required_field_missing')} if r_data[:type].blank? || r_data[:name].blank? || r_data[:nameserver].blank? 

        re = DNS_ORIGIN_ZONE_REGEX
        return r_data[:nameserver].match?(re) ?  {success: true} :  {success: false,msg: "Invalid NS value"}
      elsif r_data[:type].eql?"TXT"

        return r_data[:type].blank? || r_data[:name].blank? || r_data[:content].blank? ?  {success: false,msg: I18n.t('isp_config.required_field_missing')} :  {success: true}
      end
    end
  

    def host_zone_record_params
      params.permit(:name,:type,:ipv4,:ipv6,:publickey,:dkim,:target,:mailserver,:priority,:nameserver,:content,:hosted_zone_id,:ttl, :id, :client_id, :primary_id).merge!({hosted_zone_id: @hosted_zone.isp_config_host_zone_id,client_id: current_spree_user.isp_config_id})
    end

    def set_hosted_zone
      @hosted_zone = current_spree_user.hosted_zones.find_by_id(params[:hosted_zone_id])
     end

end

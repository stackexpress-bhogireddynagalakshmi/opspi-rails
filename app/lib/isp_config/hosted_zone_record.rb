module IspConfig
	class HostedZoneRecord < Base
    require 'dns_record_validator' 
		attr_accessor :hosted_zone_record, :reg

    def initialize hosted_zone_record
      @hosted_zone_record = hosted_zone_record
      if hosted_zone_record[:type].eql?("A")
        @hosted_zone_record[:data] = hosted_zone_record[:ipv4]
        @reg = IPV4_REGEX
      elsif hosted_zone_record[:type].eql?("AAAA")
        @hosted_zone_record[:data] = hosted_zone_record[:ipv6]
        @reg = IPV6_REGEX
      elsif hosted_zone_record[:type].eql?("CNAME")
        @hosted_zone_record[:data] = hosted_zone_record[:target]
        @reg = DNS_ORIGIN_ZONE_REGEX
      elsif hosted_zone_record[:type].eql?("MX")
        @hosted_zone_record[:data] = hosted_zone_record[:mailserver]
        @reg = DNS_ORIGIN_ZONE_REGEX
      elsif hosted_zone_record[:type].eql?("NS")
        @hosted_zone_record[:data] = hosted_zone_record[:nameserver]
        @reg = DNS_ORIGIN_ZONE_REGEX
      else
        @hosted_zone_record[:data] = hosted_zone_record[:content]
      end
    end

    def create
      res = validate_params
      return {:success => false, :message => res[:message]} unless res[:success]

        response = query({
          :endpoint => "/json.php?dns_#{hosted_zone_record[:type].downcase}_add",
          :method => :POST,
          :body => dns_record_hash
        })

        Rails.logger.debug { response.inspect}
        formatted_response(response,'create')
    end

    def update
      res = validate_params
      return {:success => false, :message => res[:message]} unless res[:success]
        response = query({
		    :endpoint => "/json.php?dns_#{hosted_zone_record[:type].downcase}_update",
		    :method => :PATCH,
		    :body => edit_dns_record_hash
			})
			Rails.logger.debug { response.inspect}
      formatted_response(response,'update')
    end

    def destroy
        response = query({
		    :endpoint => "/json.php?dns_#{hosted_zone_record[:type].downcase}_delete",
		    :method => :DELETE,
		    :body => {primary_id: hosted_zone_record[:id]} 
			})
      Rails.logger.debug { response.inspect}
			formatted_response(response,'delete')
    end

    private

    def validate_params
      validation = DnsRecordValidator.new(hosted_zone_record,type: hosted_zone_record[:type], reg: reg).call
      return {success: false, message: validation[1]} unless  validation[0]

      return {success: true}
    end

    def formatted_response(response,action)
      if  response.code == "ok"
        {
          :success=>true,
          :message=>I18n.t("isp_config.host_zone_record.#{action}"),
          response: response
        }
      else
        { 
          :success=>false,
          :message=> I18n.t('isp_config.something_went_wrong',message: response.message),
          response: response
        }
      end
    end

    def hosted_zone(hosted_zone)
      @hosted_zone ||= IspConfig::HostedZone.new(hosted_zone)
     end
   
    def dns_record_hash
      {
        "params": {
        server_id:       ENV['ISP_CONFIG_DNS_SERVER_ID'],
        zone:            hosted_zone_record[:hosted_zone_id], 
        name:            hosted_zone_record[:name],
        type:            hosted_zone_record[:type],
        data:            hosted_zone_record[:data],
        aux:             hosted_zone_record[:priority],
        ttl:             hosted_zone_record[:ttl],
        active:          'y',
        stamp:           DateTime.now.strftime("%y-%m-%d %H:%M:%S"),
        serial:          "1"
        }
      }
    end

    def edit_dns_record_hash
      {
        "client_id":    hosted_zone_record[:client_id],
        "primary_id":   hosted_zone_record[:primary_id],
        "params": {
        server_id:       ENV['ISP_CONFIG_DNS_SERVER_ID'],
        zone:            hosted_zone_record[:hosted_zone_id], 
        name:            hosted_zone_record[:name],
        type:            hosted_zone_record[:type],
        data:            hosted_zone_record[:data],
        aux:             hosted_zone_record[:priority],
        ttl:             hosted_zone_record[:ttl],
        active:          'y',
        stamp:           DateTime.now.strftime("%y-%m-%d %H:%M:%S"),
        serial:          "1"
        }
      }
    end

  end
end
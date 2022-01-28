module IspConfig
	class HostedZoneRecord < Base
		attr_accessor :hosted_zone_record

    def initialize hosted_zone_record
      @hosted_zone_record = hosted_zone_record
      if hosted_zone_record[:type].eql?("A")
        @hosted_zone_record[:data] = hosted_zone_record[:ipv4]
      elsif hosted_zone_record[:type].eql?("AAAA")
        @hosted_zone_record[:data] = hosted_zone_record[:ipv6]
      elsif hosted_zone_record[:type].eql?("CNAME")
        @hosted_zone_record[:data] = hosted_zone_record[:target]
      elsif hosted_zone_record[:type].eql?("DKIM")
        @hosted_zone_record[:data] = hosted_zone_record[:dkim]
      elsif hosted_zone_record[:type].eql?("MX")
        @hosted_zone_record[:data] = hosted_zone_record[:mailserver]
      elsif hosted_zone_record[:type].eql?("NS")
        @hosted_zone_record[:data] = hosted_zone_record[:nameserver]
      else
        @hosted_zone_record[:data] = hosted_zone_record[:content]
      end
    end

    def create
        response = query({
          :endpoint => "/json.php?dns_#{hosted_zone_record[:type].downcase}_add",
          :method => :POST,
          :body => dns_record_hash
        })

        Rails.logger.debug { response.inspect}
        if response.code == "ok"
          {:success=>true, :message=>I18n.t('isp_config.host_zone_record_created')} 
        else
          {:success=>false,:message=> I18n.t('isp_config.something_went_wrong_dns_reord',message: response.message)}
        end
    end

    def update
        response = query({
		    :endpoint => "/json.php?dns_#{hosted_zone_record[:type].downcase}_update",
		    :method => :PATCH,
		    :body => edit_dns_record_hash
			})
			Rails.logger.debug { response.inspect}
        if response.code == "ok"
          {:success=>true, :message=>I18n.t('isp_config.host_zone_record_updated')}
        else
          {:success=>false,:message=> I18n.t('isp_config.something_went_wrong_dns_reord_update',message: response.message)}
        end
    end

    def destroy
        response = query({
		    :endpoint => "/json.php?dns_#{hosted_zone_record[:type].downcase}_delete",
		    :method => :DELETE,
		    :body => {primary_id: hosted_zone_record[:id]} 
			})
      Rails.logger.debug { response.inspect}
			if  response.code == "ok"
				{:success=>true, :message=>I18n.t('isp_config.host_zone_record_deleted')}
			else
			 msg = "Something went wrong while Deleting Record. Error: #{response.message}"
			   		{:success=>false,:message=> msg}
			end
    end

    private

    def hosted_zone(hosted_zone)
      @hosted_zone ||= IspConfig::HostedZone.new(hosted_zone)
     end
   
    def dns_record_hash
      {
        "params": {
        server_id:       1,
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
        server_id:       1,
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
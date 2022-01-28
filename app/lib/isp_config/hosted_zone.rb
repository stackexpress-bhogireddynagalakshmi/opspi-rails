module IspConfig
	class HostedZone < Base
		attr_accessor :hosted_zone

    def initialize hosted_zone
      @hosted_zone = hosted_zone
    end

    def create
      if hosted_zone.isp_config_host_zone_id.blank?
        response = query({
          :endpoint => '/json.php?dns_zone_add',
          :method => :POST,
          :body => dns_hash
        })

        Rails.logger.debug { response.inspect}
        if response.code == "ok"
          hosted_zone.isp_config_host_zone_id = response.response
          hosted_zone.save
          {:success=>true, :message=>I18n.t('isp_config.host_zone_created')} 
        else
          {:success=>false,:message=> I18n.t('isp_config.something_went_wrong_dns',message: response.message)}
        end
      end
    end

    def get_all_hosted_zone_records
      response = query({
		    :endpoint => '/json.php?dns_rr_get_all_by_zone',
		    :method => :GET,
		    :body => {zone_id: hosted_zone.isp_config_host_zone_id}
			})
			if  response.code == "ok"
				{:success=>true, response: response}
			else
			 msg = "Something went wrong while Retrieving Record Info. Error: #{response.message}"
			   		{:success=>false,:message=> msg}
      end   
    end
    private

    def hosted_zone_record
      @hosted_zone_record ||= IspConfig::HostedZoneRecord.new(self)
    end

    def dns_hash
      {
        "client_id":     hosted_zone.user.isp_config_id,
        "params": {
        server_id:       1,
        origin:          hosted_zone.name,
        ns:              "one",
        mbox:            "zonemaster.test.tld.",
        serial:          "1",
        refresh:         "28800",
        retry:           "7200",
        expire:          "604800",
        minimum:         "86400",
        ttl:             "86400",
        active:          hosted_zone.status.eql?("1") ? 'y' : 'n',
        xfer:            "",
        also_notify:     "",
        update_acl:      ""
        }
      }
    end


    end
end
module IspConfig
	class HostedZone < Base
		attr_accessor :hosted_zone, :user

    def initialize hosted_zone
      @hosted_zone = hosted_zone
    end

    def all_zones
      if hosted_zone.user.isp_config_id.present?
        response = query({
          :endpoint => '/json.php?dns_zone_get_by_user',
          :method => :GET,
          :body => { 
            client_id: hosted_zone.user.isp_config_id,
            server_id: ENV['ISP_CONFIG_DNS_SERVER_ID']
          }}
        )
        response.response.reject!{|x| host_zone_ids.exclude?(x.id.to_i)}
        formatted_response(response,'all')
      else
        {:success=>false} 
      end
    end

    def create
      response = query({
        :endpoint => '/json.php?dns_zone_add',
        :method => :POST,
        :body => dns_hash
      })

      Rails.logger.debug { response.inspect}
      if response.code == "ok"
        @user = Spree::User.find_by_isp_config_id(hosted_zone[:isp_config_id])
        user.hosted_zones.create({isp_config_host_zone_id: response["response"]}) if response.code == "ok"
        {:success=>true, :message=>I18n.t('isp_config.host_zone.create')} 
      else
        {:success=>false,:message=> I18n.t('isp_config.something_went_wrong',message: response.message)}
      end
    end

    def get_zone
      response = query({
        :endpoint => '/json.php?dns_zone_get',
        :method => :GET,
        :body => { 
          primary_id: hosted_zone.isp_config_host_zone_id
        }}
      )
      formatted_response(response,'get')
    end

    def destroy(primary_id)
      response = query({
      :endpoint => "/json.php?dns_zone_delete",
      :method => :DELETE,
      :body => {primary_id: primary_id} 
      })
      Rails.logger.debug { response.inspect}
      formatted_response(response,'delete')
    end

    def update(primary_id)
      response = query({
      :endpoint => "/json.php?dns_zone_update",
      :method => :PUT,
      :body => dns_hash.merge({primary_id: primary_id})
      })
      Rails.logger.debug { response.inspect}
      formatted_response(response,'update')
    end

    def get_all_hosted_zone_records
      response = query({
		    :endpoint => '/json.php?dns_rr_get_all_by_zone',
		    :method => :GET,
		    :body => {zone_id: hosted_zone.isp_config_host_zone_id}
			})
			formatted_response(response,'all_records')
    end

    private

    def formatted_response(response,action)
      if  response.code == "ok"
        {
          :success=>true,
          :message=>I18n.t("isp_config.host_zone.#{action}"),
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

    def host_zone_ids
      @user = Spree::User.find_by_isp_config_id(hosted_zone.user.isp_config_id)
      user.hosted_zones.pluck(:isp_config_host_zone_id)
    end
    
    def dns_hash
      {
        "client_id":     hosted_zone[:isp_config_id],
        "params": {
        server_id:       ENV['ISP_CONFIG_DNS_SERVER_ID'],
        origin:          hosted_zone[:name],
        ns:              hosted_zone[:ns],
        mbox:            hosted_zone[:mbox],
        serial:          "1",
        refresh:         hosted_zone[:refresh],
        retry:           hosted_zone[:retry],
        expire:          hosted_zone[:expire],
        minimum:         hosted_zone[:minimum],
        ttl:             hosted_zone[:ttl],
        active:          hosted_zone[:status].eql?("1") ? 'y' : 'n',
        xfer:            hosted_zone[:xfer],
        also_notify:     hosted_zone[:also_notify],
        update_acl:      hosted_zone[:update_acl]
        }
      }
    end

    end
end
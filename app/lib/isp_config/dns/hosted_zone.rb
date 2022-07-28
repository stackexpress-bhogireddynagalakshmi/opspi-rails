# frozen_string_literal: true

module IspConfig
  module Dns
    class HostedZone < Base
      attr_accessor :hosted_zone, :user

      def initialize(user)
        @user = user
        set_base_uri( user.panel_config["dns"] )
      end

      def all_zones
        if user.isp_config_id.present?
          response = query({
                             endpoint: '/json.php?dns_zone_get_by_user',
                             method: :GET,
                             body: {
                               client_id: user.isp_config_id,
                               server_id: ENV['ISP_CONFIG_DNS_SERVER_ID']
                             }
                           })

          response.response.reject! { |x| host_zone_ids.exclude?(x.id.to_i) }
          formatted_response(response, 'all')
        else
          { success: false }
        end
      end

      def create(create_params)
        dns_hash = dns_hash(create_params)
        response = query({
                           endpoint: '/json.php?dns_zone_add',
                           method: :POST,
                           body: dns_hash
                         })

       
        if response.code == "ok"
          user_domain_id = get_user_domain_id(create_params[:name])

          user.hosted_zones.create({ 
            isp_config_host_zone_id: response["response"], 
            name:  create_params[:name],
            user_domain_id: user_domain_id
          })

          create_ns_records(response["response"] , create_params)
          # create_a_records(response["response"] , create_params)
          # create_mx_record(response["response"], create_params)

          { success: true, message: I18n.t('isp_config.host_zone.create'), response: response }
        else
          { success: false, message: I18n.t('isp_config.something_went_wrong', message: response.message) }
        end
      end

      def create_ns_records(host_zone_id,create_params)
        ns_record_params = {
                          type: "NS",
                          name: create_params[:name],
                          hosted_zone_name: nil,
                          ttl: "3600",
                          hosted_zone_id: host_zone_id
                        }
        nameservers = [{nameserver: ENV['ISPCONFIG_DNS_SERVER_NS1']},{nameserver: ENV['ISPCONFIG_DNS_SERVER_NS2']}]
        nameservers.each do |ns|
          user.isp_config.hosted_zone_record.create(ns_record_params.merge(ns))
        end   
      end

      #  def create_a_records(host_zone_id,create_params)
      #   ns_record_params = {
      #                     type: "A",
      #                     name: create_params[:name],
      #                     ipv4: ENV['ISPCONFIG_WEB_SERVER_IP'],
      #                     ttl: "60",
      #                     hosted_zone_id: host_zone_id
      #                   }
       
      #    user.isp_config.hosted_zone_record.create(ns_record_params)
      # end

      #  def create_mx_record(hosted_zone_id, params)
      #    ns_record_params = {
      #                     type: "MX",
      #                     name: params[:name],
      #                     mailserver: "mail.#{get_sanitized_domain(params[:name])}",
      #                     ttl: 60,
      #                     priority: 60,
      #                     hosted_zone_id: hosted_zone_id
      #                   }

      #    response = user.isp_config.hosted_zone_record.create(ns_record_params)
      # end

      def get_zone(id)
        response = query({
                           endpoint: '/json.php?dns_zone_get',
                           method: :GET,
                           body: {
                             primary_id: id
                           }
                         })
        formatted_response(response, 'get')
      end

      def destroy(primary_id)
        response = query({
                           endpoint: "/json.php?dns_zone_delete",
                           method: :DELETE,
                           body: { primary_id: primary_id }
                         })
        
        user.hosted_zones.find_by_isp_config_host_zone_id(primary_id).destroy if response.code == "ok"
        formatted_response(response, 'delete')
      end

      def update(update_params, primary_id)
        dns_hash = dns_hash(update_params)
        response = query({
                           endpoint: "/json.php?dns_zone_update",
                           method: :PUT,
                           body: dns_hash.merge({ primary_id: primary_id })
                         })
        
        formatted_response(response, 'update')
      end

      def get_all_hosted_zone_records(id)
        response = query({
                           endpoint: '/json.php?dns_rr_get_all_by_zone',
                           method: :GET,
                           body: { zone_id: id }
                         })
        formatted_response(response, 'all_records')
      end

      private

      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: I18n.t("isp_config.host_zone.#{action}"),
            response: response
          }
        else
          {
            success: false,
            message: I18n.t('isp_config.something_went_wrong', message: response.message),
            response: response
          }
        end
      end

      def host_zone_ids
        user.hosted_zones.pluck(:isp_config_host_zone_id)
      end

      def dns_hash(hosted_zone)
        {
          "client_id": user.isp_config_id,
          "params": {
            server_id: ENV['ISP_CONFIG_DNS_SERVER_ID'],
            origin: hosted_zone[:name]+".",
            ns: ENV['ISPCONFIG_DNS_SERVER_NS1']+".",
            mbox: mbox(hosted_zone[:mbox])+".",
            serial: "1",
            refresh: hosted_zone[:refresh],
            retry: hosted_zone[:retry],
            expire: hosted_zone[:expire],
            minimum: hosted_zone[:minimum],
            ttl: hosted_zone[:ttl],
            active: hosted_zone[:status].eql?("1") ? 'y' : 'n',
            xfer: hosted_zone[:xfer],
            also_notify: hosted_zone[:also_notify],
            update_acl: hosted_zone[:update_acl]
          }
        }
      end

      def mbox(mail_box)
        mail_box.sub('@','.')
      end

      def get_sanitized_domain(domain)
        domain.gsub("www.", '')
      end

      def get_user_domain_id(domain)
        user_domain = user.user_domains.where(domain: domain).last
        return nil if user_domain.blank?

        user_domain.update_column(:success, true)

        user_domain.id
      end
    end
  end
end

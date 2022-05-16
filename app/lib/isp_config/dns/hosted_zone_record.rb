# frozen_string_literal: true

module IspConfig
  module Dns
    class HostedZoneRecord < Base
      require 'dns_record_validator'
      attr_accessor :user, :reg

      def initialize(user)
        @user = user
      end

      def create(create_params)
        res = validate_params(create_params)
        return { success: false, message: res[:message] } unless res[:success]

        dns_record_hash = dns_record_hash(create_params) if res[:success]
        response = query({
                           endpoint: "/json.php?dns_#{create_params[:type].downcase}_add",
                           method: :POST,
                           body: dns_record_hash
                         })

        Rails.logger.debug { response.inspect }
        formatted_response(response, 'create')
      end

      def update(update_params)
        res = validate_params(update_params)
        return { success: false, message: res[:message] } unless res[:success]

        dns_record_hash = dns_record_hash(update_params) if res[:success]
        response = query({
                           endpoint: "/json.php?dns_#{update_params[:type].downcase}_update",
                           method: :PATCH,
                           body: dns_record_hash.merge({ primary_id: update_params[:primary_id] })
                         })
        Rails.logger.debug { response.inspect }
        formatted_response(response, 'update')
      end

      def destroy(delete_params)
        response = query({
                           endpoint: "/json.php?dns_#{delete_params[:type].downcase}_delete",
                           method: :DELETE,
                           body: { primary_id: delete_params[:id] }
                         })
        Rails.logger.debug { response.inspect }
        formatted_response(response, 'delete')
      end

      private

      def validate_params(record_params)
        case record_params[:type]
        when "A"
          record_params[:data] = record_params[:ipv4]
          reg = IPV4_REGEX
        when "AAAA"
          record_params[:data] = record_params[:ipv6]
          reg = IPV6_REGEX
        when "CNAME"
          record_params[:data] = record_params[:target]
          reg = DNS_ORIGIN_ZONE_REGEX
        when "MX"
          record_params[:data] = record_params[:mailserver]
          reg = DNS_ORIGIN_ZONE_REGEX
        when "NS"
          record_params[:data] = record_params[:nameserver]
          reg = DNS_ORIGIN_ZONE_REGEX
        else
          record_params[:data] = record_params[:content]
        end
        validation = DnsRecordValidator.new(record_params, type: record_params[:type], reg: reg).call
        return { success: false, message: validation[1] } unless validation[0]

        { success: true }
      end

      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: I18n.t("isp_config.host_zone_record.#{action}"),
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

      # def hosted_zone(hosted_zone)
      #   @hosted_zone ||= IspConfig::HostedZone.new(hosted_zone)
      # end

      def dns_record_hash(hosted_zone_record)
        {
          "client_id": hosted_zone_record[:client_id],
          "params": {
            server_id: ENV['ISP_CONFIG_DNS_SERVER_ID'],
            zone: hosted_zone_record[:hosted_zone_id],
            name: hosted_zone_record[:name],
            type: hosted_zone_record[:type],
            data: hosted_zone_record[:data],
            aux: hosted_zone_record[:priority],
            ttl: hosted_zone_record[:ttl],
            active: 'y',
            stamp: DateTime.now.strftime("%y-%m-%d %H:%M:%S"),
            serial: "1"
          }
        }
      end
    end
  end
end

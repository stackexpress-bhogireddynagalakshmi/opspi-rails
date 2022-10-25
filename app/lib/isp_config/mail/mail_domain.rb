# frozen_string_literal: true

module IspConfig
  module Mail
    class MailDomain < Base
      attr_accessor :user

      def initialize(user)
        @user = user
        set_base_uri(user.panel_config["mail"])
      end

      def find(id)
        response = query({
                           endpoint: '/json.php?mail_domain_get',
                           method: :GET,
                           body: {
                             primary_id: id
                           }
                         })

        formatted_response(response, 'find')
      end

      def create(params = {})
        response = query({
                           endpoint: '/json.php?mail_domain_add',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             params: params.merge(server_params)
                           }
                         })
        if response.code == "ok"
          create_mx_records(params)
          user.mail_domains.create({ isp_config_mail_domain_id: response["response"] }) # TODO: legacy table to be removed

          user_domain = user.user_domains.where(domain: params[:domain]).last
          user_domain.create_user_mail_domain({ user_domain_id: user_domain.try(:id),
                                                remote_mail_domain_id: response["response"] })
        end

        formatted_response(response, 'create')
      end

      def update(id, params = {})
        user_domain_mail = UserMailDomain.find(id)
        response = query({
                           endpoint: '/json.php?mail_domain_update',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: primary_id,
                             params: params.merge(server_params)
                           }
                         })

        formatted_response(response, 'update')
      end

      def destroy(id)
        user_mail_domain = UserMailDomain.find(id)
        response = query({
                           endpoint: '/json.php?mail_domain_delete',
                           method: :DELETE,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: user_mail_domain.remote_mail_domain_id
                           }
                         })

        if response.code == "ok"
          user.mail_domains.find_by_isp_config_mail_domain_id(user_mail_domain.remote_mail_domain_id)&.destroy # TODO: legacy  table, to be removed
          user_mail_domain.destroy
        end

        formatted_response(response, 'delete')
      end

      def all
        response = query({
                           endpoint: '/json.php?mail_domain_get',
                           method: :GET,
                           body: {
                             primary_id: "-1"
                           }
                         })
        response.response.reject! { |x| mail_domain_ids.exclude?(x.domain_id.to_i) }

        formatted_response(response, 'list')
      end

      private

      def create_mx_records(params)
        dns_id = HostedZone.where(name: params[:domain]).pluck(:isp_config_host_zone_id).first
        mx_records = [IspConfig::Config.api_mx_server_1(user), IspConfig::Config.api_mx_server_1(user)]
        mx_records.each do |mx|
          mx_record_params = {
            type: "MX",
            name: params[:domain],
            mailserver: mx,
            ttl: "3600",
            priority: 60,
            hosted_zone_id: dns_id,
            client_id: user.isp_config_id
          }
          user.isp_config.hosted_zone_record.create(mx_record_params)
        end
      end

      def mail_domain_ids
        user.mail_domains.pluck(:isp_config_mail_domain_id)
      end

      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: I18n.t("isp_config.mail_domain.#{action}"),
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

      def server_params
        {
          server_id: IspConfig::Config.api_web_server_id(user)
        }
      end
    end
  end
end

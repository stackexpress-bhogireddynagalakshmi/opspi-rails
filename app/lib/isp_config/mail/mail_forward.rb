# frozen_string_literal: true

module IspConfig
  module Mail
    class MailForward < Base
      attr_accessor :user

      def initialize(user)
        @user = user
        set_base_uri( user.panel_config["mail"] )
      end

      def find(id)
        response = query({
                           endpoint: '/json.php?mail_forward_get',
                           method: :GET,
                           body: {
                             primary_id: id
                           }
                         })

        formatted_response(response, 'find')
      end

      def create(params = {})
        response = query({
                           endpoint: '/json.php?mail_forward_add',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             params: params.merge(server_params)
                           }
                         })
        user.mail_forwards.create({ isp_config_mail_forward_id: response["response"] }) if response.code == "ok"

        formatted_response(response, 'create')
      end

      def update(primary_id, params = {})
        response = query({
                           endpoint: '/json.php?mail_forward_update',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: primary_id,
                             params: params.merge(server_params)
                           }
                         })

        formatted_response(response, 'update')
      end

      def destroy(primary_id)
        response = query({
                           endpoint: '/json.php?mail_forward_delete',
                           method: :DELETE,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: primary_id
                           }
                         })
        user.mail_forwards.find_by_isp_config_mail_forward_id(primary_id).destroy if response.code == "ok"
        formatted_response(response, 'delete')
      end

      def all
        response = query({
                           endpoint: '/json.php?mail_forward_get',
                           method: :GET,
                           body: {
                             primary_id: "-1"
                           }
                         })
        response.response.reject! { |x| mail_forward_ids.exclude?(x.forwarding_id.to_i) }

        formatted_response(response, 'list')
      end

      private

      def mail_forward_ids
        user.mail_forwards.pluck(:isp_config_mail_forward_id)
      end

      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: I18n.t("isp_config.mail_forward.#{action}"),
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
          server_id: ENV['ISP_CONFIG_WEB_SERVER_ID']
        }
      end
    end
  end
end

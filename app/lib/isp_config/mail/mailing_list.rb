# frozen_string_literal: true

module IspConfig
  module Mail
    class MailingList < Base
      attr_accessor :user

      def initialize(user)
        @user = user
      end

      def find(id)
        response = query({
                           endpoint: '/json.php?mail_mailinglist_get',
                           method: :GET,
                           body: {
                             primary_id: id
                           }
                         })

        formatted_response(response, 'find')
      end

      def create(params = {})
        response = query({
                           endpoint: '/json.php?mail_mailinglist_add',
                           method: :POST,
                           body: {
                             client_id: user.isp_config_id,
                             params: params.merge(server_params)
                           }
                         })
        user.mailing_lists.create({ isp_config_mailing_list_id: response["response"] }) if response.code == "ok"

        formatted_response(response, 'create')
      end

      def update(primary_id, params = {})
        response = query({
                           endpoint: '/json.php?mail_mailinglist_update',
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
                           endpoint: '/json.php?mail_mailinglist_delete',
                           method: :DELETE,
                           body: {
                             client_id: user.isp_config_id,
                             primary_id: primary_id
                           }
                         })
        user.mailing_lists.find_by_isp_config_mailing_list_id(primary_id).destroy if response.code == "ok"
        formatted_response(response, 'delete')
      end

      def all
        response = query({
                           endpoint: '/json.php?mail_mailinglist_get',
                           method: :GET,
                           body: {
                             primary_id: "-1"
                           }
                         })
        response.response.reject! { |x| maillist_ids.exclude?(x.mailinglist_id.to_i) }

        formatted_response(response, 'list')
      end

      private

      def maillist_ids
        user.mailing_lists.pluck(:isp_config_mailing_list_id)
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
          server_id: ENV['ISP_CONFIG_WEB_SERVER_ID']
        }
      end
    end
  end
end

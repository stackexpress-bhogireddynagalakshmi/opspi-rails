# frozen_string_literal: true

module IspConfig
  module Mail
    class MailStatistic < Base
      attr_accessor :user

      def initialize(user)
        @user = user
        set_base_uri( user.panel_config["mail"] )
      end

      def all_mailbox_quotas
        response = query({
                           endpoint: '/json.php?mailquota_get_by_user',
                           method: :GET,
                           body: {
                             client_id: @user.isp_config_id
                           }
                         })

        formatted_response(response, 'list')
      end

      def all_mailbox_traffic
        # response = query({
        #   :endpoint => '/json.php?mailquota_get_by_user',
        #   :method => :GET,
        #   :body => {
        #     client_id: @user.isp_config_id
        #   }}
        # )

        # formatted_response(response,'list')
      end

      private

      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: I18n.t("isp_config.mail_statistic.#{action}"),
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

# frozen_string_literal: true

module IspConfig
    class QuotaDashboard < Base
      attr_accessor :user

      def initialize(user)
        @user = user
      end
  
      def domain_quota
        response = query({
                           endpoint: '/json.php?quota_get_by_user',
                           method: :GET,
                           body: {
                             client_id: user.isp_config_id
                           }
                         })

        formatted_response(response, 'domain_quota')

      end

      def mail_quota
        response = query({
                           endpoint: '/json.php?mailquota_get_by_user',
                           method: :GET,
                           body: {
                             client_id: user.isp_config_id
                           }
                         })
  
        formatted_response(response, 'mail_quota')
      end

      def database_quota
        response = query({
                           endpoint: '/json.php?databasequota_get_by_user',
                           method: :GET,
                           body: {
                             client_id: user.isp_config_id
                           }
                         })
  
        formatted_response(response, 'database_quota')
      end
  
      def web_traffic
        response = query({
                           endpoint: '/json.php?trafficquota_get_by_user',
                           method: :GET,
                           body: {
                             client_id: user.isp_config_id
                           }
                         })

        formatted_response(response, 'web_traffic')

      end

      def ftp_traffic
        response = query({
                           endpoint: '/json.php?ftptrafficquota_data',
                           method: :GET,
                           body: {
                             client_id: user.isp_config_id
                           }
                         })

        formatted_response(response, 'ftp_traffic')

      end
  
      private
  
      def formatted_response(response, action)
        if  response.code == "ok"
          {
            success: true,
            message: "Response #{action}",
            response: response.response
          }
        else
          {
            success: false,
            message: I18n.t('isp_config.something_went_wrong', message: response.message),
            response: response
          }
        end
      end
  
    end
  end
  
module ChatWoot
    class User < Base
      attr_accessor :user
  
      def initialize(user)
        @user = user
      end
  
      def create(params = {})
        response = query({
                           endpoint: "/platform/#{ChatWoot::Config.api_version}/users",
                           method: :POST,
                           header: authorization_header,
                           body: {
                            name: "external",
                            channel: {
                              type: "web_widget",
                              website_url: "en",
                              widget_color: "blue"
                            }
                           }
                         })
  
        formatted_response(response, 'create')
      end
  
     
      private
  
     
      def formatted_response(response, action)
        if response.url?
          {
            success: true,
            message: I18n.t("isp_config.ftp_user.#{action}"),
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
  
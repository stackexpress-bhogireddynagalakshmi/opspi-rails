module SitePro
  class SiteBuilder < Base
   
    def create(params = {})
      response = query({
                         endpoint: '/requestLogin',
                         method: :POST,
                         header: authorization_header,
                         body: {
                          type: "external",
                          domain: params[:mail_domain],
                          apiUrl: "http://builder.opspi.com/",
                          lang: "en",
                          username: params[:username],
                          password: params[:password],
                          uploadDir: "/public_html"
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

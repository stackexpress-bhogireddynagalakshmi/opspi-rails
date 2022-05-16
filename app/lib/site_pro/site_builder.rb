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
                          apiUrl: SitePro::Config.api_url,
                          lang: "en",
                          username: params[:username],
                          password: params[:password],
                          uploadDir: "/web"
                         }
                       })

      formatted_response(response, 'create')
    end

   
    private

   
    def formatted_response(response, action)
      unless response.nil?
        {
          success: true,
          message: I18n.t("isp_config.ftp_user.#{action}"),
          response: response
        }
      else
        {
          success: false,
          message: I18n.t('isp_config.something_went_wrong', message: "Site builder server failure"),
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

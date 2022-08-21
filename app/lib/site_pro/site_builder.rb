module SitePro
  class SiteBuilder < Base
    attr_accessor :user

    def initialize user
      @user = user
    end
   
    def create(params = {})
      response = query({
                         endpoint: '/requestLogin',
                         method: :POST,
                         header: authorization_header,
                         body: {
                          type: "external",
                          domain: params[:dns_domain_name],
                          apiUrl: web_server_ip(user,params[:server_type]),
                          lang: "en",
                          username: params[:username],
                          password: params[:password],
                          uploadDir: upload_dir(params[:server_type], params[:username])
                         }
                       })

      formatted_response(response, 'create')
    end

   
    private

    def upload_dir(server_type, user_name)
      (server_type == "linux") ? "/web" : "/#{user_name}"
    end
   
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
          message: I18n.t('isp_config.something_went_wrong', message: response.error.message),
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

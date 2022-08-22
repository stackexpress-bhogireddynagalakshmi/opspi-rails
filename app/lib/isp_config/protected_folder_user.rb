module IspConfig
  class ProtectedFolderUser < Base
    attr_accessor :user

    def initialize(user)
      @user = user
      set_base_uri( user.panel_config["web_linux"] )
    end

    def find(id)
      response = query({
                         endpoint: '/json.php?sites_web_folder_user_get',
                         method: :GET,
                         body: {
                           primary_id: id
                         }
                       })

      formatted_response(response, 'find')
    end

    def create(params = {})
      response = query({
                         endpoint: '/json.php?sites_web_folder_user_add',
                         method: :POST,
                         body: {
                           client_id: user.isp_config_id,
                           params: params.merge(server_params)
                         }
                       })

      user.protected_folder_users.create({ isp_config_protected_folder_user_id: response["response"] }) if response.code == "ok"

      formatted_response(response, 'create')
    end

    def update(primary_id, params = {})
      response = query({
                         endpoint: '/json.php?sites_web_folder_user_update',
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
                         endpoint: '/json.php?sites_web_folder_user_delete',
                         method: :DELETE,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: primary_id
                         }
                       })

      user.protected_folder_users.find_by_isp_config_protected_folder_user_id(primary_id).destroy if response.code == "ok"
      formatted_response(response, 'delete')
    end

    def all
      response = query({
                         endpoint: '/json.php?sites_web_folder_user_get',
                         method: :GET,
                         body: {
                           primary_id: "-1"
                         }
                       })

      response.response&.reject! { |x| protected_folder_user_ids.exclude?(x.web_folder_user_id.to_i) } if response.response

      formatted_response(response, 'list')
    end

    private

    def protected_folder_user_ids
      user.protected_folder_users.pluck(:isp_config_protected_folder_user_id)
    end

    def formatted_response(response, action)
      if  response.code == "ok"
        {
          success: true,
          message: I18n.t("isp_config.website.#{action}"),
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

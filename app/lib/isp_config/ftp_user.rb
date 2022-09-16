# frozen_string_literal: true

module IspConfig
  class FtpUser < Base
    attr_accessor :user

    def initialize(user)
      @user = user
      set_base_uri( user.panel_config["web_linux"] )
    end

    def find(id)
      response = query({
                         endpoint: '/json.php?sites_ftp_user_get',
                         method: :GET,
                         body: {
                           primary_id: id
                         }
                       })

      formatted_response(response, 'find')
    end

    def create(params = {}, opts={})
      response = query({
                         endpoint: '/json.php?sites_ftp_user_add',
                         method: :POST,
                         body: {
                           client_id: user.isp_config_id,
                           params: params.merge(server_params)
                         }
                       })

      
      if response.code == 'ok'
        user.ftp_users.create({ isp_config_ftp_user_id: response["response"] })
        user_domain = opts[:user_domain]
        user_domain.user_ftp_users.create(ftp_user_params(params).merge({ remote_ftp_user_id: response["response"] })) if user_domain.present?
      end

      formatted_response(response, 'create')
    end

    def update(id, params = {})
      ftp_user = UserFtpUser.find(id)
      response = query({
                         endpoint: '/json.php?sites_ftp_user_update',
                         method: :POST,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: ftp_user.remote_ftp_user_id,
                           params: params.merge(server_params)
                         }
                       })

       if response.code == "ok"
          ftp_user.update(ftp_user_params(params))
        end


      formatted_response(response, 'update')
    end

    def destroy(id)
      ftp_user = UserFtpUser.find(id)
      response = query({
                         endpoint: '/json.php?sites_ftp_user_delete',
                         method: :DELETE,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: ftp_user.remote_ftp_user_id
                         }
                       })

      if response.code == "ok"
        user.ftp_users.find_by_isp_config_ftp_user_id(ftp_user.remote_ftp_user_id).destroy 
        ftp_user.destroy
      end

      formatted_response(response, 'delete')
    end

    def all
      response = query({
                         endpoint: '/json.php?sites_ftp_user_get',
                         method: :GET,
                         body: {
                           primary_id: "-1"
                         }
                       })

      response.response&.reject! { |x| ftp_user_ids.exclude?(x.ftp_user_id.to_i) }

      formatted_response(response, 'list')
    end

    private

    def ftp_user_ids
      user.ftp_users.pluck(:isp_config_ftp_user_id)
    end

    def formatted_response(response, action)
      if  response.code == "ok"
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
        server_id: IspConfig::Config.api_web_server_id(user)
      }
    end

    def ftp_user_params(params)
      {
        username: params[:username],
        dir: params[:dir],
        active: params[:active] == 'y'
      }.reject{|k, v| v.blank?}

    end
  end
end

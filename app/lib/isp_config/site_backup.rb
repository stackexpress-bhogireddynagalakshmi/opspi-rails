# frozen_string_literal: true

module IspConfig
  class SiteBackup < Base
    attr_accessor :user

    def initialize(user)
      @user = user
      set_base_uri( user.panel_config["web_linux"] )
    end


    def all(id)
      user_website = UserWebsite.find(id)
      response = query({
                         endpoint: '/json.php?sites_web_domain_backup_list',
                         method: :GET,
                         body: {
                           primary_id: user_website.remote_website_id
                         }
                       })


      formatted_response(response, 'list')
    end

    
    def start_backup(id, params = {})
      user_website = UserWebsite.find(id)
      response = query({
                         endpoint: '/json.php?sites_web_domain_update',
                         method: :POST,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: user_website.remote_website_id,
                           params: params.merge(start_backup_Params)
                         }
                       })

      if response.code == 'ok'
        user_website.update(enable_backup: true)
      end

      formatted_response(response, 'start')
    end

    def stop_backup(id, params = {})
      user_website = UserWebsite.find(id)
      response = query({
                         endpoint: '/json.php?sites_web_domain_update',
                         method: :POST,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: user_website.remote_website_id,
                           params: params.merge(stop_backup_Params)
                         }
                       })

      if response.code == 'ok'
        user_website.update(enable_backup: false)
      end

      formatted_response(response, 'stop')
    end

    private

    def start_backup_Params
      {
        backup_interval:    'daily',
        backup_copies:       5,
        backup_format_web:  'default',
        backup_format_db:   'gzip',
      }
    end

    def stop_backup_Params
      {
        backup_interval:    '',
        backup_copies:       1,
        backup_format_web:  'default',
        backup_format_db:   'gzip',
      }
    end

    def formatted_response(response, action)
      if  response.code == "ok"
        {
          success: true,
          message: I18n.t("backup.#{action}"),
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

  end
end

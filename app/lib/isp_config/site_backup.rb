# frozen_string_literal: true

module IspConfig
  class SiteBackup < Base
    attr_accessor :user

    def initialize(user)
      @user = user
      set_base_uri( user.panel_config["web_linux"] )
    end

    
    def update(id, params = {})
      user_website = UserWebsite.find(id)
      response = query({
                         endpoint: '/json.php?sites_web_domain_update',
                         method: :POST,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: user_website.remote_website_id,
                           params: params.merge(backup_Params)
                         }
                       })

      formatted_response(response, 'update')
    end

    def backup_Params
      {
        backup_interval: 'daily',
        backup_copies: 5,
        backup_format_web: 'default',
        backup_format_db: 'gzip',
      }
    end
  end
end

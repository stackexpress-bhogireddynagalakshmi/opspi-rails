# frozen_string_literal: true

module IspConfig
  class Database < Base
    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def create(create_params)
      ## create db user
      database_hash = database_hash(create_params)
      response = query({
                          endpoint: '/json.php?sites_database_add',
                          method: :POST,
                          body: database_hash
                        })

      Rails.logger.debug { response.inspect }
      if response.code == "ok"
        user.hosted_zones.create({ isp_config_host_zone_id: response["response"] }) if response.code == "ok"
        { success: true, message: I18n.t('isp_config.host_zone.create') }
      else
        { success: false, message: I18n.t('isp_config.something_went_wrong', message: response.message) }
      end
    end


    private

    def formatted_response(response, action)
      if  response.code == "ok"
        {
          success: true,
          message: I18n.t("isp_config.host_zone.#{action}"),
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


    def database_hash(database_params)
      {
        "client_id": database_params[:isp_config_id],
        "params": {
          server_id: ENV['ISP_CONFIG_WEB_SERVER_ID'],
          type: "mysql",
          website_id: database_params[:web_domain_id],
          database_name: database_params[:database_name],
          database_user_id: "1",
          database_ro_user_id: "0",
          database_charset: "",
          remote_access: "y",
          remote_ips: "",
          backup_interval: "none",
          backup_copies: 1,
          active: 'y'
        }
      }
    end
  end
end
  
# frozen_string_literal: true

module IspConfig
  class Database < Base
    attr_accessor :user

    def initialize(user)
      @user = user
      set_base_uri( user.panel_config["database_mysql"] )
    end

    def all
      response = query({
                         endpoint: '/json.php?sites_database_get_all_by_user',
                         method: :GET,
                         body: {
                           client_id: user.isp_config_id
                         }
                       })

      response.response&.reject! { |x| database_ids.exclude?(x.database_id.to_i) }

      formatted_response(response, 'list')
    end

    def create(create_params)
      ## create db user
      db_user_response = create_database_user(create_params)
      unless db_user_response[:success]
        return { success: false, message: I18n.t('isp_config.something_went_wrong', message: db_user_response[:message]),
                 response: db_user_response }
      end

      database_hash = database_hash(create_params.merge(db_username: db_user_response[:response][:response]))
      response = query({
                         endpoint: '/json.php?sites_database_add',
                         method: :POST,
                         body: database_hash
                       })

      user.isp_databases.create({ isp_config_database_id: response["response"] }) if response.code == "ok"

      formatted_response(response, 'create')
    end

    def create_database_user(params)
      body_params = {
        client_id: user.isp_config_id,
        params: {
          server_id: ENV['ISP_CONFIG_WEB_SERVER_ID'],
          database_user: formatted_database_name(params[:database_name]),
          database_password: params[:database_password]
        }
      }

      response = query({
                         endpoint: '/json.php?sites_database_user_add',
                         method: :POST,
                         body: body_params
                       })

      formatted_response(response, 'create')
    end

    def update_database_user_password(database_user_id, params)
      response = query({
                         endpoint: '/json.php?sites_database_user_update',
                         method: :POST,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: database_user_id,
                           params: {
                             database_password: params[:database_password]
                           }
                         }
                       })

      formatted_response(response, 'update')
    end

    def destroy(primary_ids)
      ## destroy db user
      db_user_delete_response = destroy_database_user(primary_ids[:db_user_id])
      unless db_user_delete_response[:success]
        return { success: false,
                 message: I18n.t('isp_config.something_went_wrong', message: db_user_delete_response[:message]), 
                 response: db_user_delete_response }
      end

      response = query({
                         endpoint: '/json.php?sites_database_delete',
                         method: :DELETE,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: primary_ids[:id]
                         }
                       })

      user.isp_databases.find_by_isp_config_database_id(primary_ids[:id]).destroy if response.code == "ok"

      formatted_response(response, 'delete')
    end

    def destroy_database_user(db_user_id)
      response = query({
                         endpoint: '/json.php?sites_database_user_delete',
                         method: :DELETE,
                         body: {
                           client_id: user.isp_config_id,
                           primary_id: db_user_id
                         }
                       })

      formatted_response(response, 'delete')
    end

    def find(id)
      response = query({
                         endpoint: '/json.php?sites_database_get',
                         method: :GET,
                         body: {
                           primary_id: id
                         }
                       })

      formatted_response(response, 'find')
    end

    private

    def database_ids
      user.isp_databases.pluck(:isp_config_database_id)
    end

    def formatted_response(response, action)
      if  response.code == "ok"
        {
          success: true,
          message: I18n.t("isp_config.database.#{action}"),
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
        "client_id": user.isp_config_id,
        "params": {
          server_id: ENV['ISP_CONFIG_WEB_SERVER_ID'],
          type: "mysql",
          parent_domain_id: database_params[:web_domain_id],
          database_name: "c#{user.isp_config_id}_#{database_params[:database_name]}",
          database_user_id: database_params[:db_username],
          database_quota: "-1",
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

    def formatted_database_name(database_name)
      "c#{user.isp_config_id}_#{database_name}"
    end
  end
end

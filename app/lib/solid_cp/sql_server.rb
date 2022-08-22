# frozen_string_literal: true

module SolidCp
  class SqlServer < Base
    attr_reader :user

    def initialize(user)
      @user = user
      
      set_configurations(user, SOAP_SQL_WSDL)
    end

    operations :add_sql_database,
               :add_sql_user,
               :backup_sql_database,
               :delete_sql_database,
               :update_sql_user,
               :update_sql_database,
               :delete_sql_user,
               :get_sql_database,
               :get_sql_databases,
               :get_sql_user,
               :get_sql_users


    def get_sql_databases
      response = super(message: { package_id: user.packages.first.try(:solid_cp_package_id) })
    end
    alias all get_sql_databases

    def get_sql_database(id)
      response = super(message: { itemId: id })
    end
    alias find get_sql_database

    def get_sql_user(id)
      response = super(message: { itemId: id })
    end
    alias find_db_user get_sql_user

    def get_sql_users
      response = super(message: { package_id: user.packages.first.try(:solid_cp_package_id) })
    end
    alias all_db_users get_sql_users

    def update_sql_user(id, params)
      response = super(message: {
        item: {
          "Databases" => { "string" => [params[:database_name]] },
          "Password" => params[:database_password],
          "itemId" => id,
          "PackageId" => user.packages.first.try(:solid_cp_package_id),
        }
      }
      )
      code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
      error = SolidCp::ErrorCodes.get_by_code(code)

      if response.success? && code.positive?
        { success: true, message: I18n.t(:'windows.database.create'), response: response }
      else
        { success: false, message: I18n.t(:panel_error, msg: error[:msg]), response: response }
      end
    end
    alias update_database_user_password update_sql_user
    # <item>
    #   <DataName>string</DataName> name
    #   <DataPath>string</DataPath>
    #   <DataSize>int</DataSize> 8192
    #   <LogName>string</LogName> test_root_2_data
    #   <LogPath>string</LogPath> test_root_2_log
    #   <LogSize>int</LogSize> 8192
    #   <Users>
    #     <string>string</string>
    #     <string>string</string>
    #   </Users>
    #   <Location>string</Location>
    #   <InternalServerName>string</InternalServerName>
    #   <ExternalServerName>string</ExternalServerName>
    # </item>
    # <groupName>string</groupName>

    def add_sql_database(params = {})
      database_user = user.user_databases.create(
        {
          database_name: params[:database_name],
          database_type: params[:database_type],
          user_domain_id: params[:user_domain_id]
        }
      )
      response = super(message: {
        item: {
          "Name" => params[:database_name],
          "PackageId" => user.packages.first.try(:solid_cp_package_id)
          # "Users" =>  {"string" => ["syed002"]},
        },
        group_name: "MsSQL2019"
      }
      )

      code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
      error = SolidCp::ErrorCodes.get_by_code(code)

      if response.success? && code.positive?
        user_response = add_sql_user(params.merge(database_username: database_user.id))
        database_user.update(database_user: formatted_database_name(database_user.id),database_id: response.body[:add_sql_database_response][:add_sql_database_result], status: 1)
        
        user_response
      else
        database_user.update(database_user: formatted_database_name(database_user.id),status: 0)
        { success: false, message: error_message(error[:msg]), response: response }
      end
    rescue StandardError => e
      { success: false, message: I18n.t(:panel_error, msg: e.message), response: response }
    end
    alias create add_sql_database

    def add_sql_user(params)
      response = super(message: {
        item: {
          "Databases" => { "string" => [params[:database_name]] },
          "PackageId" => user.packages.first.try(:solid_cp_package_id),
          "Name" => formatted_database_name(params[:database_username]),
          "Password" => params[:database_password]
        },
        group_name: "MsSQL2019"
      }
      )

      code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
      error = SolidCp::ErrorCodes.get_by_code(code)
      if response.success? && code.positive?
        { success: true, message: I18n.t(:'windows.database.create'), response: response }
      else
        { success: false, message: error_message(error[:msg]), response: response }
      end
    rescue StandardError => e
      { success: false, message: I18n.t(:panel_error, msg: e.message), response: response }
    end

    def delete_sql_database(id)
      response = super(message: { itemId: id })

      code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
      error = SolidCp::ErrorCodes.get_by_code(code)

      if response.success?
        { success: true, message: I18n.t(:'windows.database.delete'), response: response }
      else
        { success: false, message: I18n.t(:panel_error, msg: e.message), response: response }
      end
    end
    alias destroy delete_sql_database

    def formatted_database_name(database_username)
      "du_#{database_username.to_s.rjust(8, padstr='0')}"
    end

    def error_message(error)
      if error.include?('package item exists')
        error = "Error: Database already exists"
      else
        error.humanize
      end
    end
  end
end

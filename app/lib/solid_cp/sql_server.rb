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

    def get_sql_users
      response = super(message: { package_id: user.packages.first.try(:solid_cp_package_id) })
    end

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
      # database_user = add_sql_user(params)
      # return { success: false, message: 'Something went wrong. Please try again.'} unless database_user[:success]
      response = super(message: {
        item: {
          "Name" => params[:database_name],
          "PackageId" => user.packages.first.try(:solid_cp_package_id)
          # "Users" =>  {"string" => ["syed002"]},
        },
        group_name: "MsSQL2019" #params[:group_name]
      }
      )

      code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
      error = SolidCp::ErrorCodes.get_by_code(code)

      if response.success? && code.positive?
        user_response = add_sql_user(params)
        user.user_databases.create(
          {
            database_name: params[:database_name],
            database_user: params[:database_username],
            database_type: params[:database_type],
            database_id: response.body[:add_sql_database_response][:add_sql_database_result],
            user_domain_id: params[:user_domain_id]
          }
        )
        user_response
      else
        { success: false, message: I18n.t(:panel_error, msg: error[:msg]), response: response }
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
          "Name" => params[:database_username],
          "Password" => params[:database_password]
        },
        group_name: "MsSQL2019"  #params[:group_name]
      }
      )

      code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
      error = SolidCp::ErrorCodes.get_by_code(code)
      if response.success? && code.positive?
        { success: true, message: I18n.t(:'windows.database.create'), response: response }
      else
        { success: false, message: I18n.t(:panel_error, msg: error[:msg]), response: response }
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
  end
end

module TaskManager
  module HostingPanelTasks
    class DatabaseTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_database'
          create_database
        when 'update_database'

        when 'delete_database'

        end 
      end

      private

      def create_database
        @response = database_api.create(resource_params)
      end

      def database_api
        if windows?
          windows_api
        else
          @user.isp_config.database
        end
      end

      def windows?
        @data[:server_type].present? && @data[:server_type] == 'windows'
      end

      def windows_api
        @user.solid_cp.sql_server
      end


      def resource_params
        if windows?
          @data[:group_name] = 'MsSQL2019'
          @data[:database_username] = database_username(task[:domain])
          @data[:database_type] = 'ms_sql2019'
         return  @data
        else
          response  = user.isp_config.website.all
          if response[:success]
            websites = response[:response].response
            website  = websites.detect {|x| x.domain == task[:domain]}
            @data[:web_domain_id] = website.domain_id
            @data[:database_username] = database_username(task[:domain])
            @data[:database_type] = 'my_sql'
            return @data
          else
            raise "Something went wrong: #{response[:error]}"
          end
        end
      end

      def database_username(database_name)
        if windows?
          "c#{@user.solid_cp_id}_#{database_name}"
        else
          "c#{@user.isp_config_id}_#{database_name}"
        end
      end

      def get_folder_path
        { can_read: true, can_write: true, folder: "\\#{@data[:domain]}\\wwwroot" }
      end

    end
  end
end
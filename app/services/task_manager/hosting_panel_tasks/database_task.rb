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
        @user.solid_cp.database
      end


      def resource_params
        response  = user.isp_config.website.all
        if response[:success]
          websites = response[:response].response
          website  = websites.detect {|x| x.domain == task[:domain]}
          @data[:web_domain_id] = website.domain_id
          return @data
        else
          raise "Something went wrong: #{response[:error]}"
        end
      end

      def get_folder_path
        { can_read: true, can_write: true, folder: "\\#{@data[:domain]}\\wwwroot" }
      end

    end
  end
end
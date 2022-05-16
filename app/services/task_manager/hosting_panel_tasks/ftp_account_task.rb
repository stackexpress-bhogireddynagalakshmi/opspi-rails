module TaskManager
  module HostingPanelTasks
    class FtpAccountTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_ftp_account'
          create_ftp_account
        when 'update_ftp_account'
        when 'delete_ftp_account'
        end 
      end

      private

      def create_ftp_account
        @response = ftp_user_api.create(resource_params)
      end

      def ftp_user_api
        if windows?
          windows_api
        else
          @user.isp_config.ftp_user
        end
      end

      def windows?
        @data[:server_type].present? && @data[:server_type] == 'windows'
      end

      def windows_api
        @user.solid_cp.ftp_account
      end


      def resource_params

        response  = user.isp_config.website.all

        if response[:success]
          websites = response[:response].response
          website  = websites.detect {|x| x.domain == task[:domain]}

          @data[:parent_domain_id] = website.domain_id
          @data[:uid] = website.system_user
          @data[:gid]  =website.system_group
          @data[:dir] = website.document_root

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
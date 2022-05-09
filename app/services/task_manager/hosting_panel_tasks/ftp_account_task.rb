module TaskManager
  module HostingPanelTasks
    class FtpAccountTask < TaskManager::HostingPanelTasks::Base
      def call
        case task[:type]
        when 'create_ftp_account'
        when 'update_ftp_account'
        when 'delete_ftp_account'
        end 
      end
    end
  end
end
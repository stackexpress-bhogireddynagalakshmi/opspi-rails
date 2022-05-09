module TaskManager
  module HostingPanelTasks
    class MailBoxTask < TaskManager::HostingPanelTasks::Base
      def call
        case task[:type]
        when 'create_mail_box'
        when 'update_mail_box'
        when 'delete_mail_box'
        end 
      end
    end
  end
end
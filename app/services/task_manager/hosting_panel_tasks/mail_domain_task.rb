module TaskManager
  module HostingPanelTasks
     class MailDomainTask < TaskManager::HostingPanelTasks::Base
      def call
        case task[:type]
        when 'create_mail_domain'
        when 'update_mail_domain'
        when 'delete_mail_domain'
        end 
      end
    end
  end
end
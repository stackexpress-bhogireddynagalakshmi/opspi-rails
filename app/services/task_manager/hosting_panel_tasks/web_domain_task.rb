module TaskManager
  module HostingPanelTasks
    class WebDomainTask < TaskManager::HostingPanelTasks::Base
      def call
        case task[:type]
        when 'create_web_domain'
        when 'update_web_domain'
        when 'delete_web_domain'
        end 
      end
    end
  end
end
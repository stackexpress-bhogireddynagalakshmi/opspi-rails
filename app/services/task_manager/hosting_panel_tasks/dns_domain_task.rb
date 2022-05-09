module TaskManager
  module HostingPanelTasks
    class DnsDomainTask < TaskManager::HostingPanelTasks::Base
      def call
        case task[:type]
        when 'create_dns_domain'
        when 'update_dns_domain'
        when 'delete_dns_domain'
        end
      end
    end
  end
end
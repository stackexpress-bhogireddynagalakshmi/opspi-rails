module TaskManager
  module HostingPanelTasks
    class DnsDomainTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_dns_domain'
          create_dns_domain
        when 'update_dns_domain'
        when 'delete_dns_domain'
        end
      end

      private
      def create_dns_domain
        @response = isp_config_api.create(resource_params)
      end

      def isp_config_api
        user.isp_config.hosted_zone
      end
    end
  end
end

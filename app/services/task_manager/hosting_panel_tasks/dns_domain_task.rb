module TaskManager
  module HostingPanelTasks
    class DnsDomainTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_dns_domain'
          create_dns_domain
        when 'update_dns_domain'
        when 'delete_dns_domain'
          delete_dns_domain
        end
      end

      private
      def create_dns_domain
        @response = isp_config_api.create(resource_params)
      end

      def delete_dns_domain
         @response = isp_config_api.destroy(@user_domain.hosted_zone.isp_config_host_zone_id)

        if @response[:success]
          @user_domain.destroy
         end
      end

      def isp_config_api
        user.isp_config.hosted_zone
      end
    end
  end
end

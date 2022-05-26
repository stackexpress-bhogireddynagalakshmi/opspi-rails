module TaskManager
  module HostingPanelTasks
    class DnsRecordTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_dns_record'
          create_dns_record
        when 'update_dns_record'
        when 'delete_dns_record'
        end
      end

      private
      def create_dns_record
        @response = isp_config_api.create(resource_params)
      end

      def resource_params
        response  = user.isp_config.hosted_zone.all_zones

        if response[:success]
          hosted_zones = response[:response].response
          hosted_zone  = hosted_zones.detect{|x| x.origin == @task[:domain]}
          hosted_zone  = hosted_zones.detect{|x| x.origin == "#{@task[:domain]}."} if hosted_zone.blank?

          @data[:hosted_zone_id] = hosted_zone.id

          return @data
        else
          raise "Something went wrong: #{response[:error]}"
        end
      end

      def isp_config_api
        user.isp_config.hosted_zone_record
      end
    end
  end
end

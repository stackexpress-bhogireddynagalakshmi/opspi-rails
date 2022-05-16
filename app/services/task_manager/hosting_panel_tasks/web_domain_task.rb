module TaskManager
  module HostingPanelTasks
    class WebDomainTask < TaskManager::HostingPanelTasks::Base
      
      def call
        case task[:type]
        when 'create_web_domain'
          create_web_domain
        when 'update_web_domain'
        when 'delete_web_domain'
        end
      end

      private

      def create_web_domain
        @response = web_domain_api.create(resource_params)
      end

      def web_domain_api
        if @data[:server_type].present? && @data[:server_type] == 'windows'
          windows_api
        else
          @user.isp_config.website
        end
      end

      def windows_api
        @user.solid_cp.web_domain
      end

      def resource_params
        if @data[:server_type].present? && @data[:server_type] == 'windows'
          windows_resource_params
        else
          @data.merge!(extra_isp_params) # updating data hash
          super  #calling parent method to create proper params now
        end
      end

      def extra_isp_params
        { type: 'vhost', parent_domain_id: 0, vhost_type: 'name', cgi: 'y', ssi: 'y', suexec: 'y',
          errordocs: 1, is_subdomainwww: 1, ruby: 'n', ssl: 'n', stats_type: 'webalizer',
          allow_override: 'All', php_open_basedir: '/', pm: 'ondemand', pm_max_requests: 0,
          pm_process_idle_timeout: 10, backup_copies: 1, backup_format_web: 'default',
          backup_format_db: 'gzip', traffic_quota_lock: 'n', http_port: '80', https_port: '443'
        }
      end

      def windows_resource_params
        { domain_name:  @data["domain"], create_webSite: "1", enable_dns: "0", allow_subdomains: "1" }
      end

    end
  end
end
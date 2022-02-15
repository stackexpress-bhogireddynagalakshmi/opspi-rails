module Spree
  module Admin
     module Sites
      class WebsitesController < Spree::Admin::IspConfigResourcesController

        private
        def resource_id_field
          "isp_config_website_id"
        end

        def assoc
          "websites"
        end

        def resource_params
          request_params.merge(extra_isp_params)
        end

        def request_params
          params.require("website").permit(:ip_address, :ipv6_address, :domain, :subdomain, :hd_quota, :traffic_quota, :active, :php)
        end

        def resource_index_path
          redirect_to admin_sites_websites_path
        end

        def isp_config_api
          current_spree_user.isp_config.website
        end

        def extra_isp_params
          {
            ip_address: '*',
            type: 'vhost',
            parent_domain_id: 0,
            vhost_type: 'name',
            hd_quota: -1,
            traffic_quota: -1,
            cgi: 'y',
            ssi: 'y',
            suexec: 'y',
            errordocs: 1,
            is_subdomainwww: 1,
            subdomain: 'www',
            php: 'y',
            ruby: 'n',
            # redirect_type: '',
            # redirect_path: '',
            ssl: 'n',
            # ssl_state: '',
            # ssl_locality: '',
            # ssl_organisation: '',
            # ssl_organisation_unit: '',
            # ssl_country: '',
            # ssl_domain: '',
            # ssl_request: '',
            # ssl_key: '',
            # ssl_cert: '',
            # ssl_bundle: '',
            # ssl_action: '',
            # stats_password: '',
            stats_type: 'webalizer',
            allow_override: 'All',
            # apache_directives: '',
            php_open_basedir: '/',
            pm: 'ondemand',
            pm_max_requests: 0,
            pm_process_idle_timeout: 10,
            # custom_php_ini: '',
            # backup_interval: '',
            backup_copies: 1,
            backup_format_web: 'default',
            backup_format_db: 'gzip',
            # active: 'y',
            traffic_quota_lock: 'n',
            http_port: '80',
            https_port: '443'
          }
        end

      end
    end
  end
end

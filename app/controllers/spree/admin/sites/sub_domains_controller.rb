module Spree
  module Admin
     module Sites
      class SubDomainsController < Spree::Admin::IspConfigResourcesController
        before_action :get_websites, only: [:new, :create]

        private
        def resource_id_field
          "isp_config_sub_domain_id"
        end

        def assoc
          "sub_domains"
        end

        def resource_params
          request_params.merge(extra_isp_params)
        end

        def request_params
          params.require("sub_domain").permit(:domain ,:parent_domain_id)
        end

        def resource_index_path
          redirect_to admin_sites_sub_domains_path
        end

        def isp_config_api
          current_spree_user.isp_config.sub_domain
        end

        def get_websites
          response = current_spree_user.isp_config.website.all || []
          if response[:success]
            @websites  = response[:response].response
          else
            @websites = []
          end
        end

        def extra_isp_params
          {
            # server_id: 1,
            ip_address: '*',
            # domain: 'tsssssubt.int',
            type: 'subdomain',
            # parent_domain_id: 1,
            vhost_type: '',
            document_root: '/web/dom',
            system_user: 'benutzer',
            system_group: 'gruppe',
            hd_quota: 100000,
            traffic_quota: -1,
            cgi: 'y',
            ssi: 'y',
            suexec: 'y',
            errordocs: 1,
            is_subdomainwww: 1,
            subdomain: '',
            php: 'y',
            ruby: 'n',
            redirect_type: '',
            redirect_path: '',
            ssl: 'n',
            ssl_state: '',
            ssl_locality: '',
            ssl_organisation: '',
            ssl_organisation_unit: '',
            ssl_country: '',
            ssl_domain: '',
            ssl_request: '',
            ssl_cert: '',
            ssl_bundle: '',
            ssl_action: '',
            stats_password: '',
            stats_type: 'webalizer',
            allow_override: 'All',
            apache_directives: '',
            php_open_basedir: '/php',
            custom_php_ini: '',
            backup_interval: '',
            backup_copies: 1,
            active: 'y',
            traffic_quota_lock: 'n'


          }
        end

      end
    end
  end
end

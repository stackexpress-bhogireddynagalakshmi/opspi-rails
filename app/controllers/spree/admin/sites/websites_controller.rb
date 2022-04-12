# frozen_string_literal: true

module Spree
  module Admin
    module Sites
      class WebsitesController < Spree::Admin::IspConfigResourcesController
        before_action :get_zone_list, only: [:new, :create]


       def index
          response = isp_config_api.all || []
          @resources = if response[:success]
                         response[:response].response
                       else
                         []
                       end

          @response = windows_api.all || []
          @windows_resources = convert_to_mash(@response.body[:get_domains_response][:get_domains_result][:domain_info]) rescue []
        end
        private

        def resource_id_field
          "isp_config_website_id"
        end

        def assoc
          "websites"
        end

        def resource_params
          if params[:server_type].present? && params[:server_type] == 'windows'
            windows_resource_params
          else
            request_params.merge(extra_isp_params)
          end
        end

        def request_params
          params.require("website").permit(:ip_address, :ipv6_address, :domain, :hd_quota, :traffic_quota, :subdomain, :php, :active)
        end

        def resource_index_path
          redirect_to admin_sites_websites_path
        end

        def isp_config_api
          if params[:server_type].present? && params[:server_type] == 'windows'
            windows_api
          else
            current_spree_user.isp_config.website
          end
        end

        def windows_api
          current_spree_user.solid_cp.web_domain
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
          { domain_name:  params[:website]["domain"], create_webSite: "1", enable_dns: "0", allow_subdomains: "1" }
        end

      end
    end
  end
end

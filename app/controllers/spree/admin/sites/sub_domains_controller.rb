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
          params.require("sub_domain").permit(:parent_domain_id).merge(domain: convert_sub_domain)
        end

        def convert_sub_domain
          params[:parent_domain_name].present? ? (params[:sub_domain][:domain] + "." + params[:parent_domain_name]) : params[:sub_domain][:domain] 
        end

        def resource_index_path
          redirect_to admin_sites_sub_domains_path
        end

        def isp_config_api
          current_spree_user.isp_config.sub_domain
        end

        def get_websites
          response = current_spree_user.isp_config.website.all || []
          @websites = response[:success] ? response[:response].response : []
        end

        def extra_isp_params
          { 
            server_id: 1,
            # domain: "k.syednew1.com",
            type: "subdomain",
            # parent_domain_id: 51,
            document_root: "/web/dom",
            system_user: "benutzer",
            system_group: "gruppe",
            hd_quota: 100000,
            traffic_quota: -1,
            cgi: "y",
            ssi: "y",
            suexec: "y",
            errordocs: 1,
            is_subdomainwww: 1,
            subdomain: "1",
            php: "y",
            ruby: "n",
            ssl: "n",
            stats_type: "webalizer",
            allow_override: "All",
            apache_directives: "",
            php_open_basedir: "/php",
            backup_copies: 1,
            active: "y",
            traffic_quota_lock: "n"
          }
        end

      end
    end
  end
end

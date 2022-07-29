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


          @response = windows_api.all || [] rescue []

          @windows_resources = convert_to_mash(@response.body[:get_domains_response][:get_domains_result][:domain_info]) rescue []
        end

        def enable_webservice
          response = windows_api.create(resource_params)
          if response[:success]
            @response = create_ftp(params)
          end
          set_flash
          redirect_to request.referrer
        end

        def create_ftp(params)
          current_spree_user.solid_cp.ftp_account.create(ftp_windows_params(params))
        end       
        
        def ftp_windows_params(params)
          { 
            folder: "\\#{params[:website][:domain]}\\wwwroot",
            username: set_ftp_username(params[:website][:domain]).first(20),
            password: SecureRandom.urlsafe_base64.first(16),
            can_read: true,
            can_write: true
          }
        end

        def update_isp_ssl
          if params[:website][:ssl] == 'y'
            ensure_a_record(params)
          end
          
          @response = current_spree_user.isp_config.website.update(params[:web_site_id],{domain: params[:website][:domain],ssl: params[:website][:ssl], ssl_letsencrypt: params[:website][:ssl]})
          set_flash
          redirect_to request.referrer
        end


        def ensure_a_record(params)
          dns_records = current_spree_user.isp_config.hosted_zone.get_all_hosted_zone_records(params[:website][:dns_id])[:response].response
          a_records = dns_records.select{|x| x[:id] if x[:type] == 'A' && x[:data] == ENV['ISPCONFIG_WEB_SERVER_IP']}

          create_a_record(params) if a_records.blank?
        end

        def create_a_record(a_rec_params)
          
          a_record_params={
            type: "A",
            name: a_rec_params[:website][:domain],
            hosted_zone_name: nil,
            ipv4: ENV['ISPCONFIG_WEB_SERVER_IP'],
            ttl: "3600",
            hosted_zone_id: a_rec_params[:website][:dns_id],
            client_id: current_spree_user.isp_config_id
          }
          current_spree_user.isp_config.hosted_zone_record.create(a_record_params)
        end

        def enable_disable_web_domain
          if params[:web_site_id].to_i > 0
            response = isp_config_api.destroy(params[:web_site_id])
            if response[:success]
              ftp_users = current_spree_user.isp_config.ftp_user.find(parent_domain_id: params[:web_site_id])[:response].response
              ftp_ids = ftp_users.collect{|x| x[:ftp_user_id]}.compact
              if ftp_ids.any?
                ftp_ids.each do |ftp_id|
                  @response = current_spree_user.isp_config.ftp_user.destroy(ftp_id)
                end
              end
            end
          else
            response = isp_config_api.create({domain: params[:website][:domain]})
            if response[:success]
              website  = current_spree_user.isp_config.website.find(response[:response][:response])
              if website[:success] && website[:response]
                ftp_user_params = ftp_users_resource_params(website[:response][:response])
                @response = current_spree_user.isp_config.ftp_user.create(ftp_user_params)
              end
            end
          end
          set_flash
          redirect_to request.referrer
        end
        private

        def ftp_users_resource_params(website)
          {
            parent_domain_id: website.domain_id,
            username: set_ftp_username(params[:website][:domain]),
            password: SecureRandom.hex,
            quota_size: -1,
            active: 'y',
            uid: website.system_user,
            gid: website.system_group,
            dir: website.document_root
          }
        end

        def resource_id_field
          "isp_config_website_id"
        end

        def assoc
          "websites"
        end

        def set_ftp_username(domain)
          domain.gsub!('.', '_')
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
            errordocs: 1, is_subdomainwww: 1, ruby: 'n', ssl: 'y', stats_type: 'webalizer',
            allow_override: 'All', php_open_basedir: '/', pm: 'ondemand', pm_max_requests: 0,
            pm_process_idle_timeout: 10, backup_copies: 1, backup_format_web: 'default', active: 'y',
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

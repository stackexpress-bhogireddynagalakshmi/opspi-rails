# frozen_string_literal: true

module Spree
    module Admin
      module WebsiteBuilder
        class SiteBuildersController < Spree::Admin::BaseController

          def index; end
    
          def new; end

          def create
            dns_record_res = create_dns_record
            if dns_record_res[:success] 
              website = get_web_domain_id
              if website.present?
                ftp = get_ftp_user(website)
                if ftp.first.kind_of?(Array)
                  delete_ftp = current_spree_user.isp_config.ftp_user.destroy(ftp[0].first)
                  @new_domain_ftp_response = registration_web_ftp_user(ftp[0].last)
                else
                  @new_domain_ftp_response = registration_web_ftp_user(website.first)
                end
              else
                @new_domain_ftp_response = create_web_domain  
              end
            else
              Rails.logger.debug{@new_domain_ftp_response.inspect}
              flash[:error] = dns_record_res[:message]
              redirect_to admin_site_builder_path
            end
            if @new_domain_ftp_response[:ftp_user_response].present? && @new_domain_ftp_response[:ftp_user_response][:success]
              @response = SitePro::SiteBuilder.new().create(site_builder_params.merge({username: @new_domain_ftp_response[:ftp_user_params][:username],password: @new_domain_ftp_response[:ftp_user_params][:password]}))
              if @response[:success] 
                redirect_to "#{@response[:response].url}"
               else
                flash[:error] = @response[:message]
                redirect_to admin_site_builder_path
              end
            else
              
              Rails.logger.debug{@new_domain_ftp_response.inspect}
              flash[:error] = "Something went wrong"
              redirect_to admin_site_builder_path
            end
          end

          def create_dns_record
            host_zone_record_params = {}
            dns_response = current_spree_user.isp_config.hosted_zone.all_zones
            dns_domain = dns_response[:response].response.map{|k| k.id if k[:origin] == site_builder_params[:dns_domain_name]+"."}
            a_record_params={
              type: "A",
              name: site_builder_params[:dns_domain_name],
              hosted_zone_name: site_builder_params[:dns_domain_name],
              ipv4: ENV['ISPCONFIG_WEB_SERVER_IP'],
              ttl: "3600",
              hosted_zone_id: dns_domain.compact.first,
              client_id: current_spree_user.isp_config_id
            }

            dns_record_response = current_spree_user.isp_config.hosted_zone_record.create(a_record_params)
          end

          def get_web_domain_id
            web_response  = current_spree_user.isp_config.website.all
            web_domain_id = web_response[:response].response.map{|k| k.domain_id if k[:domain] == site_builder_params[:dns_domain_name]}
            web_domain_id.compact
          end

          def get_ftp_user(website_id)
            ftp_user_response = current_spree_user.isp_config.ftp_user.all
            # parent_domain_id = ftp_user_response[:response].response.map{|k| k.parent_domain_id}
            ftp_user = ftp_user_response[:response].response.map{|k| [k.ftp_user_id,k.parent_domain_id] if k[:username] == "#{website_id.first}_site_builder"}
            ftp_user.compact
          end

          def create_web_domain
            response = {}
            web_response  = current_spree_user.isp_config.website.create(web_params)
            response[:web_response] = web_response
            response[:web_params] = web_params
            if web_response[:success] && web_response[:response]
              ftp_user_response = registration_web_ftp_user(web_response[:response][:response])
              response.merge!(ftp_user_response)
            end
            response
          end
    
          def registration_web_ftp_user(parent_domain_id)
            response = {}
            website  = current_spree_user.isp_config.website.find(parent_domain_id)
            if website[:success] && website[:response]
              ftp_user_params = ftp_users_resource_params(website[:response][:response])
              ftp_user_response = current_spree_user.isp_config.ftp_user.create(ftp_user_params)
              response[:ftp_user_response] = ftp_user_response
              response[:ftp_user_params] = ftp_user_params
            end
            response
          end

          def ftp_update_password_params
            {
              password: SecureRandom.hex
            }
          end

          def ftp_users_resource_params(website)
            {
              parent_domain_id: website.domain_id,
              username: "#{website.domain_id}_site_builder",
              password: SecureRandom.hex,
              quota_size: -1,
              active: 'y',
              uid: website.system_user,
              gid: website.system_group,
              dir: website.document_root
            }
          end
    
          def set_ftp_username(domain)
            domain.gsub!('.', '_')
          end
          
          def web_params
            {
              domain: site_builder_params[:dns_domain_name],
              active: 'y',
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
              ssl: 'n',
              stats_type: 'webalizer',
              allow_override: 'All',
              php_open_basedir: '/',
              pm: 'ondemand',
              pm_max_requests: 0,
              pm_process_idle_timeout: 10,
              backup_copies: 1,
              backup_format_web: 'default',
              backup_format_db: 'gzip',
              traffic_quota_lock: 'n',
              http_port: '80',
              https_port: '443'
            }
          end
          
          private

          def site_builder_params
            params.permit(:dns_domain_name)
          end

        end
      end
    end
end
  
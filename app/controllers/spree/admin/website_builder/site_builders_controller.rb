module Spree
  module Admin
    module WebsiteBuilder
      class SiteBuildersController < Spree::Admin::BaseController
        include ApisHelper
        def index; end
  
        def new; end

        def create
          user_domain = UserDomain.where(id: params[:user_domain_id]).last
          opts = {user_domain: user_domain}

          if params[:server_type] == 'linux'
              website  = UserWebsite.where(user_domain_id: params[:user_domain_id]).last
              if website.present?
                ftp = UserFtpUser.where(user_domain_id: params[:user_domain_id], username: "#{website.remote_website_id}_site_builder")
                if ftp.any?
                  ftp.each do |ftp_rec|
                   current_spree_user.isp_config.ftp_user.destroy(ftp_rec.id)
                  end
                  @new_domain_ftp_response = registration_web_ftp_user(website.remote_website_id, opts)
                else
                  @new_domain_ftp_response = registration_web_ftp_user(website.remote_website_id, opts)
                end
              else
                @new_domain_ftp_response = create_web_domain(opts) 
              end
            
            if @new_domain_ftp_response[:ftp_user_response].present? && @new_domain_ftp_response[:ftp_user_response][:success]
              @response = SitePro::SiteBuilder.new(current_spree_user).create(site_builder_params.merge({username: @new_domain_ftp_response[:ftp_user_params][:username],password: @new_domain_ftp_response[:ftp_user_params][:password],server_type: params[:server_type]}))
              if @response[:success] 
                redirect_to "#{@response[:response].url}"
              else
                flash[:error] = @response[:message]
                redirect_to request.referrer
              end
            else
              
              Rails.logger.debug{@new_domain_ftp_response.inspect}
              flash[:error] = @new_domain_ftp_response[:ftp_user_response][:message]
              redirect_to request.referrer
            end
          else
              website = UserWebsite.where(user_domain_id: params[:user_domain_id]).last    # website = get_web_domain_id
              if website.present?
                ftp = UserFtpUser.where(user_domain_id: params[:user_domain_id], username: "#{website.remote_website_id}_site_builder")    # get_ftp_user(website)
               
                if ftp.any?
                  ftp.each do |ftp_rec|
                   current_spree_user.solid_cp.ftp_account.destroy(ftp_rec.id)
                  end
                  
                  ftp_acc = create_ftp_account(website.remote_website_id, opts)
                  @new_domain_ftp_response = get_window_ftp(ftp_acc)
                else
                  ftp_acc = create_ftp_account(website.remote_website_id, opts)
                  @new_domain_ftp_response = get_window_ftp(ftp_acc)
                end
              else
                @new_domain_ftp_response = create_win_web_domain(opts) 
              end

            if @new_domain_ftp_response.present? && @new_domain_ftp_response[:id].present?
              @response = SitePro::SiteBuilder.new(current_spree_user).create(site_builder_params.merge({username: @new_domain_ftp_response[:name],password: @new_domain_ftp_response[:password],folder: @new_domain_ftp_response[:folder],server_type: params[:server_type]}))
              if @response[:success] 
                redirect_to "#{@response[:response].url}"
              else
                flash.now[:error] = @response[:message]
                redirect_to request.referrer
              end
            else
              
              Rails.logger.debug{@new_domain_ftp_response.inspect}
              flash.now[:error] = "Something went wrong"
              redirect_to request.referrer
            end
          end
        end



        def get_web_domain_id
          # if params[:server_type] == "linux"
          #   web_response  = current_spree_user.isp_config.website.all
          #   web_domain_id = web_response[:response].response.map{|k| k.domain_id if k[:domain] == site_builder_params[:dns_domain_name]}
          #   web_domain_id.compact
          # else
            windows_resource = current_spree_user.solid_cp.website.all || [] 
            @windows_resources = windows_resource.body[:get_web_sites_response][:get_web_sites_result][:web_site] rescue []
            @windows_resources = [@windows_resources] if @windows_resources.is_a?(Hash)
            web_domain_id = @windows_resources.collect{|x| x[:id] if x[:name] == site_builder_params[:dns_domain_name]}.compact.first
          # end
        end

        # def get_ftp_user(website_id)
        #   if params[:server_type] == "linux"
        #     ftp_user_response = current_spree_user.isp_config.ftp_user.all
        #     ftp_user = ftp_user_response[:response].response.map{|k| [k.ftp_user_id,k.parent_domain_id] if k[:username] == "#{website_id.first}_site_builder"}
        #     ftp_user.compact
        #   else
        #     res = current_spree_user.solid_cp.ftp_account.all
        #     response_body = res.body[:get_ftp_accounts_response][:get_ftp_accounts_result]
        #     win_user = response_body.nil? ? [] : response_body[:ftp_account]
        #     win_user = [win_user] if win_user.is_a?(Hash)
        #     ftp_user = win_user.collect{|x| x[:id] if x[:name] == "#{website_id}_site_builder" }.compact
        #   end
        # end

        def create_ftp_account(website_id, user_domain)
          ftp_params = {
            username: "#{website_id}_site_builder", 
            password: SecureRandom.urlsafe_base64,
            can_read: true, 
            can_write: true, 
            folder: "\\#{site_builder_params[:dns_domain_name]}\\wwwroot"
          }
          response = current_spree_user.solid_cp.ftp_account.create(ftp_params, user_domain)
          response[:response].body[:add_ftp_account_response][:add_ftp_account_result] rescue []
        end

        def get_window_ftp(id)
          response = current_spree_user.solid_cp.ftp_account.find(id) || []
          response.body[:get_ftp_account_response][:get_ftp_account_result] rescue []
        end 

        def create_win_web_domain(user_domain)
          web_response = current_spree_user.solid_cp.web_domain.create({domain_name: site_builder_params[:dns_domain_name]})
          website = get_web_domain_id
          ftp_acc = create_ftp_account(website, user_domain)
          get_window_ftp(ftp_acc)
        end

        def create_web_domain(opts)
          response = {}
          web_response  = current_spree_user.isp_config.website.create(web_params)
          response[:web_response] = web_response
          response[:web_params] = web_params
          if web_response[:success] && web_response[:response]
            ftp_user_response = registration_web_ftp_user(web_response[:response][:response], opts)
            response.merge!(ftp_user_response)
          end
          response
        end

        
        def registration_web_ftp_user(parent_domain_id, opts)
          response = {}
          website  = current_spree_user.isp_config.website.find(parent_domain_id)
          if website[:success] && website[:response]
            ftp_user_params = ftp_users_resource_params(website[:response][:response])
            ftp_user_response = current_spree_user.isp_config.ftp_user.create(ftp_user_params, opts)
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
            ssl: 'y',
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
          params.permit(:dns_domain_name,:server_type)
        end

      end
    end
  end
end

module Spree
  module Admin
    class WizardsController < Spree::Admin::BaseController
      before_action :get_zone_list, only: :new

      def new; end

      def create
        @resources = {}

        website_response = registration_web_domain if request_params[:enable_web_service] == 'y'
        @resources.merge!(website_response) if website_response

        mail_response = registration_mail_domain if request_params[:enable_mail_service] == 'y'
        @resources.merge!(mail_response) if mail_response
        render :index
      end

      def index; end

      private

      def request_params
        params.require("wizard").permit(:domain, :enable_web_service, :enable_mail_service, emails: [])
      end

      def registration_web_domain
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

      def web_params
        {
          domain: request_params[:domain],
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

      def ftp_users_resource_params(website)
        {
          parent_domain_id: website.domain_id,
          username: set_ftp_username(website.domain),
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


      def registration_mail_domain
        response = {}
        mail_response  = current_spree_user.isp_config.mail_domain.create(mail_params)
        response[:mail_response] = mail_response
        response[:mail_params] = mail_params
        mail_box_response = registration_mail_box if mail_response[:success] && mail_response[:response]
        response.merge!(mail_box_response)
      end

      def mail_params
        {
          domain: request_params[:domain],
          active: 'y'
        }
      end


      def registration_mail_box
        mail_box = []
        if request_params[:emails]
          request_params[:emails].each do |email|
            response = {}
            mail_box_params = mail_box_resource_params(email)
            mail_box_response = current_spree_user.isp_config.mail_user.create(mail_box_params)
            response[:mail_box_response] = mail_box_response
            response[:mail_box_params] = mail_box_params
            mail_box << response
          end
        end
        {mail_box_responses: mail_box}
      end


      def mail_box_resource_params(email)
        {
          name: email,
          email: "#{email}@#{request_params[:domain]}",
          password: SecureRandom.hex,
          quota: "0",
          cc: "",
          forward_in_lda: "0",
          policy: "0",
          postfix: "y",
          disablesmtp: "n",
          disabledeliver: "n",
          greylisting: "n",
          disableimap: "n",
          disablepop3: "n"
        }
      end


      def get_zone_list
        response = current_spree_user.isp_config.hosted_zone.all_zones || []
        @hosted_zones  = response[:success] ? response[:response].response : []
      end

    end
  end
end

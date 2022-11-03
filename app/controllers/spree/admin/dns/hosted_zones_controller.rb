# frozen_string_literal: true

module Spree
  module Admin
    module Dns
      class HostedZonesController < Spree::Admin::BaseController
        include ApisHelper
        include PanelConfiguration

        before_action :set_user_domain, only: %i[zone_overview destroy]
        before_action :ensure_hosting_panel_access
        before_action :set_zone_list, only: %i[edit update destroy dns zone_overview]

        def index
          @user_domains = current_spree_user.user_domains
        end

        def create
          @response = dns_api.create(host_zone_params)
          set_flash
          if @response[:success]
            redirect_to admin_dns_hosted_zones_path
          else
            render :new
          end
        end

        def enable_dns_services
          @domain = params["website"]["origin"]
          @type = params["website"]["type"]

          @tasks = []

          build_tasks

          flash[:success] = I18n.t('wizards.wizard_started')

          TaskManager::TaskProcessor.new(current_spree_user, @tasks).call

          redirect_to admin_dns_hosted_zones_path
        end

        def disable_dns_services
          @response = isp_website_api.destroy(params["website"]["origin"]) if params["website"]["type"] == 'web'
          @response = mail_domain_api.destroy(params["website"]["origin"]) if params["website"]["type"] == 'mail'
          set_flash
          respond_to do |format|
            format.js { render inline: "location.reload();" }
            format.html { redirect_to  admin_dns_hosted_zones_path }
          end
        end

        def new; end

        def edit
          @response = dns_api.get_zone(@zone_list.isp_config_host_zone_id)
          @hosted_zone = @response[:response].response if @response[:success].present?
        end

        def update
          @response = dns_api.update(host_zone_params, @zone_list.isp_config_host_zone_id)
          set_flash
          if @response[:success]
            redirect_to admin_dns_hosted_zones_path
          else
            response = dns_api.get_zone(@zone_list.isp_config_host_zone_id)
            @hosted_zone = response[:response].response  if response[:success].present?
            render :edit
          end
        end

        def destroy

          @user_domain.update(active: false)
    
          TaskManager::HostingPanelTasks::DeleteDomainTaskBuilder.new(current_spree_user, user_domain_id: @user_domain.id).call
          respond_to do |format|
            format.js { render inline: "location.reload();" }
            format.html { redirect_to  admin_user_domains_path(deleted_domain_id: @user_domain.id) }
          
          end
          
        end

        def dns
          @hosted_zone_record = HostedZoneRecord.new
          @hosted_zone = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:id])
          @hosted_zone_records_reponse = dns_api.get_all_hosted_zone_records(@zone_list.isp_config_host_zone_id)
          @hosted_zone_records = @hosted_zone_records_reponse[:response][:response]
        end

        def zone_overview
          @zone_name = params[:zone_name]
          @dns_id = params[:dns_id]

          @hosted_zone_record = HostedZoneRecord.new
          @hosted_zone = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:dns_id])
          @zone_list = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:dns_id])
          @hosted_zone_records_reponse = dns_api.get_all_hosted_zone_records(@zone_list.isp_config_host_zone_id)
          @hosted_zone_records = @hosted_zone_records_reponse[:response][:response]

          @hosted_zone_records_count = if @hosted_zone_records.present?
                                         @hosted_zone_records.size
                                       else
                                         0
                                       end

          #### website windows
          if current_spree_user.have_windows_access? && @user_domain.windows?
            @windows_resource = current_spree_user.solid_cp.web_domain.all || []
            @windows_resources = begin
              @windows_resource.body[:get_domains_response][:get_domains_result][:domain_info]
            rescue StandardError
              []
            end
            @windows_websites = @windows_resources.collect { |x| x if x[:domain_name].include?(@zone_name) }.compact
            website_array = @windows_websites.collect { |c| c[:web_site_id] if c[:web_site_id].to_i.positive? }.compact

            @website_list = @windows_websites.collect { |c| c[:domain_name] if c[:web_site_id].to_i.zero? }.compact

            if website_array.any?
              website_id = current_spree_user.solid_cp.website.get_certificates_for_site({ web_site_id: website_array.first })
              @website_certificate_id = begin
                website_id.body[:get_certificates_for_site_response][:get_certificates_for_site_result][:ssl_certificate]
              rescue StandardError
                []
              end
              @website_certificate_id = [@website_certificate_id] if @website_certificate_id.is_a?(Hash)
              @website_certificate_id = @website_certificate_id.first
            end
          end

          if @user_domain.windows?
          # TODO: Yet to implement/refactor

          elsif @user_domain.linux?
            user_remote_website_response = current_spree_user.isp_config.website.find(@user_domain.user_website.try(:remote_website_id))
            @user_remote_website = user_remote_website_response[:response][:response]

          end

          # User Mail boxes
          @mailboxes = @user_domain.user_mailboxes.order("created_at desc")

          # User database
          @user_databases = current_spree_user.user_databases.where(user_domain_id: @user_domain.id).order("created_at desc")

          # FTP Users
          @ftp_users = @user_domain.user_ftp_users.order("created_at desc")

          ## Spam Filters
          @spam_filters = @user_domain.user_spam_filters.order("created_at desc")

          ## mail forward
          @mail_forwards = @user_domain.user_mail_forwards.order("created_at desc")

          # user mailing list
          @mailing_lists = @user_domain.user_mailing_lists.order("created_at desc")

          get_active

          get_phpadmin_client_url
        end

        def get_phpadmin_client_url
          ul = IspConfig::Config.user_url
          @phpmyAdminUrl = "#{ul}phpmyadmin/"
        end

        def get_config_details
          web_domain = get_web_domain_id(params[:website][:origin])

          mail_domain = get_mail_domain_id(params[:website][:origin])

          respond_to do |format|
            format.js { render json: { web: web_domain, mail: mail_domain } }
          end
        end

        private

        def build_tasks
          if @type == 'web'
            prepare_web_domain_task
            prepare_a_record_task
          end

          if @type == 'mail'
            prepare_mail_domain_task
            prepare_mx_record_task
          end

          @tasks = @tasks.flatten
        end

        def prepare_web_domain_task
          @tasks <<
            {
              id: 1,
              type: "create_web_domain",
              domain: @domain,
              data: {
                server_type: 'linux',
                ip_address: '',
                ipv6_address: '',
                domain: @domain,
                hd_quota: '-1',
                traffic_quota: '-1',
                subdomain: 'www',
                php: 'fast-cgi',
                active: 'y'
              },
              depends_on: nil,
              sidekiq_job_id: nil
            }
        end

        def prepare_a_record_task
          dns_response = dns_api.all_zones
          dns_domain = dns_response[:response].response.map { |k| k.id if k[:origin] == "#{@domain}." }
          dns_record_response = dns_api.get_all_hosted_zone_records(dns_domain.compact.first)
          dns_a_recs = dns_record_response[:response].response.map { |k| k.id if k[:type] == "A" }
          task_data = {
            id: 2,
            type: "create_dns_record",
            domain: @domain,
            data: {
              type: "A",
              name: @domain,
              ipv4: config_value_for(current_spree_user.panel_config["web_linux"], 'ISPCONFIG_WEB_SERVER_IP'),
              ttl: "3600",
              hosted_zone_id: dns_domain.compact.first
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }
          unless dns_a_recs.compact.first.blank?
            dns_a_recs.compact.each do |a_record|
              host_zone_record_api.destroy({ type: "A", id: a_record })
            end

          end
          @tasks << task_data
        end

        def prepare_mail_domain_task
          @tasks <<
            {
              id: 1,
              type: "create_mail_domain",
              domain: @domain,
              data: {
                domain: @domain,
                active: 'y'
              },
              depends_on: nil,
              sidekiq_job_id: nil
            }
        end

        def prepare_mx_record_task
          dns_response = dns_api.all_zones
          dns_domain = dns_response[:response].response.map { |k| k.id if k[:origin] == "#{@domain}." }
          dns_record_response = dns_api.get_all_hosted_zone_records(dns_domain.compact.first)
          dns_mx_recs = dns_record_response[:response].response.map { |k| k.id if k[:type] == "MX" }
          task_data = {
            id: 2,
            type: "create_dns_record",
            domain: @domain,
            data: {
              type: "MX",
              name: @domain,
              mailserver: config_value_for(current_spree_user.panel_config["web_linux"], 'ISPCONFIG_MAIL_SERVER_01'),
              ttl: 60,
              priority: 10,
              hosted_zone_id: dns_domain.compact.first
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }
          unless dns_mx_recs.compact.first.blank?
            dns_mx_recs.compact.each do |mx_record|
              host_zone_record_api.destroy({ type: "MX", id: mx_record })
            end
          end
          @tasks << task_data
        end

        def get_web_domain_id(origin)
          web_domains = isp_website_api.all
          web_domain_id = web_domains[:response].response.collect { |x| x.domain_id if x.domain.eql?(origin) }
          web_domain_id.compact.first
        end

        def get_mail_domain_id(origin)
          mail_domains = mail_domain_api.all
          mail_domain_id = mail_domains[:response].response.collect { |x| x.domain_id if x.domain.eql?(origin) }
          mail_domain_id.compact.first
        end

        def set_flash
          if @response[:success]
            flash[:success] = @response[:message]
          else
            flash.now[:error] = @response[:message]
          end
        end

        def set_zone_list
          @zone_list = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:id])
        end

        def isp_config_api
          current_spree_user.isp_config.database
        end

        def spamfilter_api
          current_spree_user.isp_config
        end

        def mailing_list_api
          current_spree_user.isp_config.mailing_list
        end

        def mail_user_api
          current_spree_user.isp_config.mail_user
        end

        def mailing_list_api
          current_spree_user.isp_config.mailing_list
        end

        def get_active
          @active_data = Website.actives
        end

        def host_zone_params
          params.require(:hosted_zones).permit(:name, :ns, :mbox, :refresh, :retry, :expire, :minimum, :ttl, :xfer,
                                               :also_notify, :update_acl, :isp_config_host_zone_id, :status).merge!({ isp_config_id: current_spree_user.isp_config_id })
        end

        def convert_to_mash(data)
          case data
          when Hash
            Hashie::Mash.new(data)
          when Array
            data.map { |d| Hashie::Mash.new(d) }
          else
            data
          end
        end
      end
    end
  end
end

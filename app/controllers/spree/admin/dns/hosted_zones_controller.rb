# frozen_string_literal: true

module Spree
  module Admin
    module Dns
      class HostedZonesController < Spree::Admin::BaseController
        include ApisHelper
        before_action :ensure_hosting_panel_access
        before_action :set_zone_list, only: %i[edit update destroy dns zone_overview]
        def index
          @response = host_zone_api.all_zones || []
          @hosted_zones = if @response[:success]
                            @response[:response].response
                          else
                            []
                          end
        end

        def create
          @response = host_zone_api.create(host_zone_params)
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
          
          flash[:success] = I18n.t('wizard.wizard_started')

          TaskManager::TaskProcessor.new(current_spree_user, @tasks).call

          redirect_to admin_dns_hosted_zones_path

        end

        def disable_dns_services
          if params["website"]["type"] == 'web'
            @response = isp_website_api.destroy(params["website"]["origin"])
          end
          if params["website"]["type"] == 'mail'
            @response = mail_domain_api.destroy(params["website"]["origin"])
          end
          set_flash
          respond_to do |format|
            format.js { render inline: "location.reload();" }
            format.html { redirect_to  admin_dns_hosted_zones_path}

          end
        end

        def new; end

        def edit
          @response = host_zone_api.get_zone(@zone_list.isp_config_host_zone_id)
          @hosted_zone = @response[:response].response if @response[:success].present?
        end

        def update
          @response = host_zone_api.update(host_zone_params, @zone_list.isp_config_host_zone_id)
          set_flash
          if @response[:success]
            redirect_to admin_dns_hosted_zones_path
          else
            response = host_zone_api.get_zone(@zone_list.isp_config_host_zone_id)
            @hosted_zone = response[:response].response  if response[:success].present?
            render :edit
          end
        end

        def destroy
          @response = host_zone_api.destroy(@zone_list.isp_config_host_zone_id)
          set_flash
          respond_to do |format|
            format.js { render inline: "location.reload();" }
            format.html { redirect_to  admin_dns_hosted_zones_path}

          end
        end

        def dns
          @hosted_zone_record = HostedZoneRecord.new
          @hosted_zone = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:id])
          @hosted_zone_records_reponse = host_zone_api.get_all_hosted_zone_records(@zone_list.isp_config_host_zone_id)
          @hosted_zone_records = @hosted_zone_records_reponse[:response][:response]
        end

        def zone_overview
          @zone_name = params[:zone_name]
          @dns_id = params[:dns_id]

          @hosted_zone_record = HostedZoneRecord.new
          @hosted_zone = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:dns_id])
          @zone_list = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:dns_id])
          @hosted_zone_records_reponse = host_zone_api.get_all_hosted_zone_records(@zone_list.isp_config_host_zone_id)
          @hosted_zone_records = @hosted_zone_records_reponse[:response][:response]

          if @hosted_zone_records.present?
            @hosted_zone_records_count = @hosted_zone_records.size
          else
            @hosted_zone_records_count = 0
          end

          @mail_user = mail_user_api.all[:response].response
          
          list_arr = []
          @mail_user.each do |element|
            if element.login.split('@')[1] == @zone_name
              list_arr << element
             @mailboxes = list_arr  
            end
          end

          if @mailboxes.present?
            @mailbox_count = @mailboxes.size
          else
            @mailbox_count = 0
          end

          @web_domain = current_spree_user.isp_config.website.all[:response].response
          for el in @web_domain
            if el.domain == @zone_name
            @resources = isp_config_api.find(parent_domain_id: el.domain_id)[:response].response
              
            @ftp_user = ftp_user_api.find(parent_domain_id: el.domain_id)[:response].response
              
          @win_user = begin
              @res = current_spree_user.solid_cp.ftp_account.all
              convert_to_mash(@res.body[:get_ftp_accounts_response][:get_ftp_accounts_result][:ftp_account])
          rescue StandardError
            []
          end
          @win_user = [@win_user].to_a.flatten
            end
          end

          if @resources.present?
            @database_count = @resources.size
          else
            @database_count = 0
          end

          if @ftp_user.present?
            @ftp_count = @ftp_user.size
          else
            @ftp_count = 0
          end

          if @win_user.present?
            @win_count = @win_user.size
          else
            @win_count = 0
          end

          get_spam_filter

          @spam_filter_black = spamfilter_api.spam_filter_blacklist.all[:response].response
          
          if @spam_filter_black.present?
            @spam_filter_black_count = @spam_filter_black.size
          else
            @spam_filter_black_count = 0
          end
          
          @mail_forward = current_spree_user.isp_config.mail_forward.all[:response].response
          list_arr1 = []
          @mail_forward.each do |elem|
            if elem.source.split('@')[1] == @zone_name
              list_arr1 << elem
             @resources3 = list_arr1  
            end
          end

          if @resources3.present?
            @mail_forward_count = @resources3.size
          else
            @mail_forward_count = 0
          end

          @mailing_list_response = mailing_list_api.all[:response].response
          list_arr2 = []
          @mailing_list_response.each do |ele|
            if ele.domain == @zone_name
              list_arr2 << ele
             @mailing_lists = list_arr2  
            end
          end

          if @mailing_lists.present?
            @mailing_list_count = @mailing_lists.size
          else
            @mailing_list_count = 0
          end

          @mail_domain_response = current_spree_user.isp_config.mail_domain.all[:response].response
          list_arr3 = []
          @mail_domain_response.each do |ele|
            if ele.domain == @zone_name
              list_arr3 << ele
             @mail_domain = list_arr3  
            end
          end

          if @mail_domain.present?
          @mail_domain_count = @mail_domain.size
          else
            @mail_domain_count = 0
          end

          @websites_response = current_spree_user.isp_config.website.all[:response].response
          list_arr4 = []
          @websites_response.each do |el|
            if el.domain == @zone_name
              list_arr4 << el
            #  @websites = list_arr4
             @domains
             @websites = list_arr4.collect { |x| [x.domain, x.domain_id] }
             @web_id = el.domain_id
             break
            else
              @websites = @websites_response.collect { |x| [x.domain, x.domain_id] }
            end
          end

          domains = current_spree_user.isp_config.mail_domain.all[:response].response
          list_arr5 = []
          domains.each do |elm|
            if elm.domain == @zone_name
              list_arr5 << elm
            #  @websites = list_arr4
              @domains = list_arr5.collect { |x| [x.domain, x.domain] }
             break
            else
              @domains = domains.collect { |x| [x.domain, x.domain] }
            end
          end

          get_active
          

        @user_mail_domains = current_spree_user.isp_config.mail_domain.all[:response].response

        end 

        def get_spam_filter
          spam = IspConfig::Mail::SpamFilterWhitelist.new(current_spree_user)
          @spam_filter_white = spam.all[:response].response
          
          if @spam_filter_white.present?
            @spam_filter_white_count = @spam_filter_white.size
          else
            @spam_filter_white_count = 0
          end
        end

        def get_config_details
          web_domain = get_web_domain_id(params[:website][:origin])

          mail_domain = get_mail_domain_id(params[:website][:origin])

          respond_to do |format|
            format.js { render json: {web: web_domain,mail: mail_domain}}
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
          dns_response = host_zone_api.all_zones
          dns_domain = dns_response[:response].response.map{|k| k.id if k[:origin] == "#{@domain}."}
          dns_record_response = host_zone_api.get_all_hosted_zone_records(dns_domain.compact.first)
          dns_a_recs = dns_record_response[:response].response.map{|k| k.id if k[:type] == "A"}
          task_data = {
            id: 2,
            type: "create_dns_record",
            domain: @domain,
            data: {
              type: "A",
              name: @domain,
              ipv4: ENV['ISPCONFIG_WEB_SERVER_IP'],
              ttl: "3600",
              hosted_zone_id: dns_domain.compact.first
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }
          unless dns_a_recs.compact.first.blank?
            dns_a_recs.compact.each do |a_record| 
              host_zone_record_api.destroy({type: "A",id: a_record})
            end
            @tasks << task_data
              
          else
            @tasks << task_data
          end
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
          dns_response = host_zone_api.all_zones
          dns_domain = dns_response[:response].response.map{|k| k.id if k[:origin] == "#{@domain}."}
          dns_record_response = host_zone_api.get_all_hosted_zone_records(dns_domain.compact.first)
          dns_mx_recs = dns_record_response[:response].response.map{|k| k.id if k[:type] == "MX"}
          task_data = {
            id: 2,
            type: "create_dns_record",
            domain: @domain,
            data: {
              type: "MX",
              name: @domain,
              mailserver: ENV['ISPCONFIG_MAIL_SERVER_01'],
              ttl: 60,
              priority: 10,
              hosted_zone_id: dns_domain.compact.first
            },
            depends_on: nil,
            sidekiq_job_id: nil
          }
          unless dns_mx_recs.compact.first.blank?
            dns_mx_recs.compact.each do |mx_record| 
              host_zone_record_api.destroy({type: "MX",id: mx_record})
            end
            @tasks << task_data             
          else
            @tasks << task_data     
          end
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

        def ftp_user_api
            current_spree_user.isp_config.ftp_user
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

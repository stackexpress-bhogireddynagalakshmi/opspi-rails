# frozen_string_literal: true

module Spree
  module Admin
    module Dns
      class HostedZonesController < Spree::Admin::BaseController
        include ApisHelper
        before_action :ensure_hosting_panel_access
        before_action :set_zone_list, only: %i[edit update destroy dns]
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
          
          flash[:success] = "Wizard Jobs Started. Your services will be activated in few miniutes"

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

        def host_zone_params
          params.require(:hosted_zones).permit(:name, :ns, :mbox, :refresh, :retry, :expire, :minimum, :ttl, :xfer,
                                               :also_notify, :update_acl, :isp_config_host_zone_id, :status).merge!({ isp_config_id: current_spree_user.isp_config_id })
        end
      end
    end
  end
end

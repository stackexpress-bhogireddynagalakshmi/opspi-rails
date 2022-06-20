# frozen_string_literal: true

module Spree
  module Admin
    module Dns
      class HostedZonesController < Spree::Admin::BaseController
        # require 'isp_config/hosted_zone'
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

        def enable_web_service
          @domain = params["website"]["web"]

          @tasks = []
          
          build_tasks

          flash[:success] = "A records will be updated"
          
          TaskManager::TaskProcessor.new(current_spree_user, @tasks).call

          redirect_to admin_dns_hosted_zones_path

        end

        def disable_web_service
          @response = isp_website_api.destroy(params["website"]["web"])
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

        private

        def build_tasks
          prepare_web_domain_task
          prepare_a_record_task
  
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
          
          unless dns_a_recs.compact.first.blank?
            dns_a_recs.compact.each do |a_record| 
              host_zone_record_api.destroy({type: "A",id: a_record})
            end
            @tasks <<
              {
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
          else
            @tasks <<
              {
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
          end
        end

        def set_flash
          if @response[:success]
            flash[:success] = @response[:message]
          else
            flash.now[:error] = @response[:message]
          end
        end

        def host_zone_api
          current_spree_user.isp_config.hosted_zone
        end

        def host_zone_record_api
          current_spree_user.isp_config.hosted_zone_record
        end

        def isp_website_api
          current_spree_user.isp_config.website
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

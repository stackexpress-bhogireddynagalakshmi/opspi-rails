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

          if VALID_DOMAIN_REGEX.match?(@domain)
            @tasks = []
            
            build_tasks(params)
            
            TaskManager::TaskProcessor.new(current_spree_user, @tasks).call
            
            flash[:success] = "Wizard Jobs Started. Your services will be activated in few miniutes"

            redirect_to admin_wizard_path(id: @batch_jobs.keys.last)
          else
            @error = 'Invalid domain name'
            render 'new'
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

        def build_tasks(web_params)
          if web_params["website"]["web"] != 'undefined'
            prepare_web_domain_task
            prepare_a_record_task
          end
  
          @tasks = @tasks.flatten
        end

        def prepare_web_domain_task
          @tasks <<
            {
              id: 2,
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

# frozen_string_literal: true

module Spree
  module Admin
    module Dns
      class HostedZonesController < Spree::Admin::BaseController
        # require 'isp_config/hosted_zone'
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

          @hosted_zone = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:dns_id])
          @zone_list = current_spree_user.hosted_zones.find_by_isp_config_host_zone_id(params[:dns_id])
          @hosted_zone_records_reponse = host_zone_api.get_all_hosted_zone_records(@zone_list.isp_config_host_zone_id)
          @hosted_zone_records = @hosted_zone_records_reponse[:response][:response]

          @user = current_spree_user.isp_config.mail_user.all
          @respon = @user[:response].response
          
          for element in  @respon
            if element.login.split('@')[1] == @zone_name
             @mailboxes = mail_user_api.find(element.mailuser_id)[:response].response      
            end
          end

          @web_domain = current_spree_user.isp_config.website.all[:response].response
          for el in @web_domain
            if el.domain == @zone_name
              @resources = isp_config_api.find(parent_domain_id: el.domain_id)[:response].response 

              @ftp_user = ftp_user_api.find(parent_domain_id: el.domain_id)[:response].response
            end
          end


        end 

        private

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

        def isp_config_api
          current_spree_user.isp_config.database
        end

        def ftp_user_api
            current_spree_user.isp_config.ftp_user
        end

        def mail_user_api
          current_spree_user.isp_config.mail_user
        end

        def host_zone_params
          params.require(:hosted_zones).permit(:name, :ns, :mbox, :refresh, :retry, :expire, :minimum, :ttl, :xfer,
                                               :also_notify, :update_acl, :isp_config_host_zone_id, :status).merge!({ isp_config_id: current_spree_user.isp_config_id })
        end
      end
    end
  end
end

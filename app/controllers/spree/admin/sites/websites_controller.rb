module Spree
  module Admin
     module Sites
      class WebsitesController < Spree::Admin::BaseController
        before_action :set_website, only: [:destroy]

        def index
          response = website_api.all || []
          if response[:success]
            @websites  = response[:response].response
          else
            @websites = []
          end
        end

        def new; end

        def create
          @response  = website_api.create(website_params)
          if @response[:success]
            set_flash
            redirect_to admin_sites_websites_path
          else
            render :new
          end
        end

        def destroy
          @response  = website_api.destroy(@website.isp_config_website_id)
          set_flash
          redirect_to admin_sites_websites_path
        end

        private

        def set_flash
          if @response[:success] 
            flash[:success] = @response[:message]
          else
            flash[:error] = @response[:message] 
          end
        end

        def website_params
          params.require("website").permit(:ip_address, :ipv6_address, :domain, :subdomain, :hd_quota, :traffic_quota, :active, :php)
        end

        def website_api
          current_spree_user.isp_config.website
        end

        def set_website
          @website = current_spree_user.websites.find_by_isp_config_website_id(params[:id])

          redirect_to admin_sites_websites_path, notice: 'Not Authorized' if @website.blank?
        end

      end
     end
  end
end

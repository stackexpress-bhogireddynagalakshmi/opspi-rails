module Spree
  module Admin
     module Sites
      class FtpUsersController < Spree::Admin::BaseController
        before_action :set_ftp_user, only: [:destroy]
        before_action :get_websites, only: [:new]

        def index
         response = ftp_user_api.all || []
          if response[:success]
            @ftp_users  = response[:response].response
          else
            @ftp_users = []
          end
        end

        def new; end

        def create
          @response  = ftp_user_api.create(ftp_user_params)
          if @response[:success]
            set_flash
            redirect_to admin_sites_ftp_users_path
          else
            get_websites
            render :new
          end
        end

        def destroy
          @response  = ftp_user_api.destroy(@ftp_user.isp_config_ftp_user_id)
          set_flash
          redirect_to admin_sites_ftp_users_path
        end

        private

        def set_flash
          if @response[:success] 
            flash[:success] = @response[:message]
          else
            flash[:error] = @response[:message] 
          end
        end
        
        def ftp_user_params
          params.require("ftp_user").permit(:parent_domain_id, :username, :password, :quota_size, :active, :uid, :gid, :dir)
        end

        def ftp_user_api
          current_spree_user.isp_config.ftp_user
        end

        def get_websites
          response = current_spree_user.isp_config.website.all || []
          if response[:success]
            @websites  = response[:response].response
          else
            @websites = []
          end
        end

        def set_ftp_user
          @ftp_user = current_spree_user.ftp_users.find_by_isp_config_ftp_user_id(params[:id])

          redirect_to admin_sites_ftp_users_path, notice: 'Not Authorized' if @ftp_user.blank?
        end

      end
     end
  end
end

# frozen_string_literal: true

module Spree
  module Admin
    module Sites
      class FtpUsersController < Spree::Admin::BaseController
        before_action :set_user_domain, only: [:new, :create, :update, :edit, :index, :destroy,:configurations]
        before_action :set_ftp_user, only: %i[destroy update configurations]
        # before_action :get_websites, only: [:new]

        include ResetPasswordConcern

        def index
          @ftp_users = @user_domain.user_ftp_users
        end

        def new
          @ftp_user = @user_domain.user_ftp_users.build
        end

        def create
          @response = ftp_user_api.create(resource_params, user_domain: @user_domain)

         if @response[:success]
            @ftp_user = @user_domain.user_ftp_users.where(username: resource_params[:username]).last 
          end
        end

        def destroy
          @response = ftp_user_api.destroy(@ftp_user.id)
        end

        def update
          @response = ftp_user_api.update(@ftp_user.id, resource_params)
          
          @ftp_user.reload
        end

        def configurations; end

        private

        def resource_params
          if windows?
            windows_resource_params
          elsif @user_domain.linux?
            linux_resource_params
          end
        end

        def linux_resource_params 
          params.require("ftp_user").permit(:username, :password).merge(linux_extra_params)
        end

        def linux_extra_params
          remote_website_id = @user_domain.user_website&.remote_website_id
          website = current_spree_user.isp_config.website.find(remote_website_id) rescue nil
          website = website[:response][:response] rescue nil
         
          data = { 
            quota_size: '-1',
            active: 'y',            
          }

          if website.present?
            data = data.merge(
              parent_domain_id: remote_website_id,
              dir: website.document_root,
              gid: website.system_group,
              uid: website.system_user
            )
          end

          data         
        end

        def windows_resource_params 
          params.require("ftp_user").permit(:username, :password).merge(get_folder_path)
        end


        def get_folder_path
          { can_read: true, can_write: true, folder: "\\#{params[:ftp_user][:domain]}\\wwwroot" }
        end

        def ftp_user_api
          if windows?
            windows_api
          else
            current_spree_user.isp_config.ftp_user
          end
        end

        def windows_api
          current_spree_user.solid_cp.ftp_account
        end

        def set_ftp_user
          @ftp_user = @user_domain.user_ftp_users.find(params[:id])

          redirect_to admin_dashboard_path, notice: 'Not Authorized' if @ftp_user.blank?
        end

        def windows?
          @user_domain.windows?
        end

      end
    end
  end
end

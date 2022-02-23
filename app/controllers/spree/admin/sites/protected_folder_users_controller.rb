module Spree
  module Admin
    module Sites
      class ProtectedFolderUsersController < Spree::Admin::IspConfigResourcesController
        before_action :get_folder_list, only: [:new, :index]

        def create
          @response = current_spree_user.isp_config.protected_folder_user.create(protected_folder_user_params)
          if @response[:success]
            set_flash
            redirect_to admin_sites_protected_folder_users_path
          else
            get_folder_list
            render :new
          end
        end

        private

        def resource_id_field
          "isp_config_protected_folder_user_id"
        end

        def assoc
          "protected_folder_users"
        end

        def resource_params
          protected_folder_user_params
        end

        def protected_folder_user_params
          params.require("protected_folder_user").permit(:web_folder_id, :username, :password, :repeat_password, :active)
        end

        def resource_index_path
          redirect_to admin_sites_protected_folder_users_path
        end

        def isp_config_api
          current_spree_user.isp_config.protected_folder_user
        end

        def get_folder_list
          response = current_spree_user.isp_config.protected_folder.all || []
          @folders = response[:success] ? response[:response].response : []
          website_response = current_spree_user.isp_config.website.all || []
          websites = website_response[:success] ? website_response[:response].response : []

          @folders.map do |folder|
            website = websites.select{|w| w if (w.domain_id == folder.parent_domain_id) }
            domain_name = website.first.domain
            path = folder["path"]
            folder["folder"] = [domain_name, path].join(' ') if domain_name.present?
          end
        end
      end
    end
  end
end

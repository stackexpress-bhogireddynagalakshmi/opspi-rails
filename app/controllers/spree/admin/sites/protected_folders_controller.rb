module Spree
  module Admin
    module Sites
      class ProtectedFoldersController < Spree::Admin::IspConfigResourcesController
        before_action :get_website_list, only: [:new, :index]

        def create
          @response = isp_config_api.create(protected_folder_params)
          if @response[:success]
            set_flash
            redirect_to admin_sites_protected_folders_path
          else
            get_website_list
            render :new
          end
        end

        private

        def resource_id_field
          "isp_config_protected_folder_id"
        end

        def assoc
          "protected_folders"
        end

        def resource_params
          protected_folder_params
        end

        def protected_folder_params
          params.require("protected_folder").permit(:parent_domain_id, :path, :active)
        end

        def resource_index_path
          redirect_to admin_sites_protected_folders_path
        end

        def isp_config_api
          current_spree_user.isp_config.protected_folder
        end

        def get_website_list
          response = current_spree_user.isp_config.website.all || []
          @websites = response[:success] ? response[:response].response : []
        end
      end
    end
  end
end

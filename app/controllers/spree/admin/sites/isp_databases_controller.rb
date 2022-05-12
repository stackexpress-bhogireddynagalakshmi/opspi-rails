# frozen_string_literal: true

module Spree
    module Admin
      module Sites
        class IspDatabasesController < Spree::Admin::IspConfigResourcesController
          before_action :get_website_list, only: [:new, :index]

          def create
            @response = isp_config_api.create(database_params)
            if @response[:success]
              set_flash
              redirect_to admin_sites_isp_databases_path
            else
              # get_website_list
              render :new
            end
          end
  
          private
  
          def resource_id_field
            "isp_config_database_id"
          end
  
          def assoc
            "isp_databases"
          end
  
          def resource_params
            database_params
          end
  
          def database_params
            params.require("database").permit(:web_domain_id, :database_name, :database_username, :database_password)
          end
  
          def resource_index_path
            redirect_to admin_sites_isp_databases_path
          end
  
          def isp_config_api
            current_spree_user.isp_config.database
          end
  
          def get_website_list
            response = current_spree_user.isp_config.database.all || []
            @websites = response[:success] ? response[:response].response : []
          end
        end
      end
    end
  end
  
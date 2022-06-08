# frozen_string_literal: true

module Spree
    module Admin
      module Sites
        class IspDatabasesController < Spree::Admin::IspConfigResourcesController

          include ResetPasswordConcern
          include ApisHelper
          
          def create
            @response = isp_config_api.create(database_params)
            if @response[:success]
              set_flash
              redirect_to admin_sites_isp_databases_path
            else
              render :new
            end
          end


        def destroy
          @response = isp_config_api.destroy(params)
          set_flash
          redirect_to admin_sites_isp_databases_path
        end

        def show
          response = isp_config_api.find(params[:id])
          @database = response[:success] ? response[:response].response : []
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
  
        end
      end
    end
  end
  
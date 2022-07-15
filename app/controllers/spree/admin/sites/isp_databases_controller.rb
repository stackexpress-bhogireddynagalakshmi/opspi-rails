# frozen_string_literal: true

module Spree
  module Admin
    module Sites
      #panel Database API Integration
      class IspDatabasesController < Spree::Admin::BaseController
        include ResetPasswordConcern
        include ApisHelper

        def index
          response = database_api.all || []
          @resources = if response[:success]
                         response[:response].response
                       else
                         []
                       end

          @windows_resources = begin
            @response = windows_api.all || []
            convert_to_mash(@response.body[:get_sql_databases_response][:get_sql_databases_result][:sql_database])
          rescue StandardError
            []
          end
          @windows_resources = [@windows_resources].to_a.flatten
        end

        def create
          @response = database_api.create(resource_params)
          if @response[:success]
            set_flash
            redirect_to admin_sites_isp_databases_path
          else
            render :new
          end
        end

        def destroy
          @response = database_api.destroy(params[:id])
          set_flash
          # redirect_to admin_sites_isp_databases_path
          redirect_to request.referrer
        end

        def show
          @response = database_api.find(params[:id])
          @database = if params[:server_type] == 'windows'
                        @response.body[:get_sql_database_response][:get_sql_database_result]
                      else
                        @response[:success] ? @response[:response].response : []
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
          if windows?
            params.require("database").permit(:group_name, :database_name, :database_password, :database_username)
          else
            isp_database_params
          end
        end

        def isp_database_params
          params.require("database").permit(:web_domain_id, :database_name, :database_username, :database_password)
        end

        def resource_index_path
          redirect_to admin_sites_isp_databases_path
        end

        def database_api
          if windows?
            windows_api
          else
            isp_config_api
          end
        end

        def isp_config_api
          current_spree_user.isp_config.database
        end

        def windows_api
          current_spree_user.solid_cp.sql_server
        end

        def windows?
          params[:server_type].present? && params[:server_type] == 'windows'
        end

        def set_flash
          if @response[:success]
            flash[:success] = @response[:message]
          else
            flash.now[:error] = @response[:message]
          end
        end

        def convert_to_mash(data)
          case data
          when Hash
            Hashie::Mash.new(data)
          when Array
            data.map { |d| Hashie::Mash.new(d) }
          else
            data
          end
        end
      end
    end
  end
end

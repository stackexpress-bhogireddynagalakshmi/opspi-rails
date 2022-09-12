# frozen_string_literal: true

module Spree
  module Admin
    module Sites
      # panel Database API Integration
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

          user_database_params = resource_params.reject { |k, _v| k == "database_password" }

          if @response[:success]
            @database = current_spree_user.user_databases.where(database_name: user_database_params[:database_name], status: 'success').last 
          end
          render "create"
        end

        def destroy
          @response = database_api.destroy(params[:id])
          set_flash
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

        def configurations
          @database = current_spree_user.user_databases.find(params[:id])
        end

        def reset_password
          @database = current_spree_user.user_databases.find(params[:id])
          if @database.database_type == 'my_sql'
            @response = database_api.find(@database.database_id)
            if @response[:success]
              db_user_id = @response[:response].response.database_user_id
              @password = SecureRandom.hex
              @response = database_api.reset_password(db_user_id, { database_password: @password })
            end
          else
            @response = database_api.all_db_users
            db_users = @response.body[:get_sql_users_response][:get_sql_users_result][:sql_user] || [] 
            db_users = [db_users] if db_users.is_a?(Hash)
            if db_users.any?
              db_user   = db_users.detect { |x| x[:name] == @database.database_user }
              @password = SecureRandom.hex
              @response = database_api.update_database_user_password(
                db_user[:id], { database_password: @password, database_name: @database.database_name }
                )
            end
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
            win_params = params.require("database").permit(:database_name, :database_password, :database_type)
            win_params = win_params.merge({ database_username: database_username(win_params[:database_name]), user_domain_id: user_domain_id })
          else
            isp_database_params
          end
        end

        def isp_database_params
          lin_params = params.require("database").permit(:web_domain_id, :database_name, :database_password, :database_type)
          lin_params = lin_params.merge({ database_username: database_username(lin_params[:database_name]), user_domain_id: user_domain_id })
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

        def user_domain_id
          current_spree_user.user_domains.collect{|x| x.id if x.domain == params[:database][:domain_name] }.compact.last
        end

        def database_username(database_name)
          if windows?
            "c#{current_spree_user.solid_cp_id}_#{database_name}"
          else
            "c#{current_spree_user.isp_config_id}_#{database_name}"
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Admin
    module Sites
      class FtpUsersController < Spree::Admin::BaseController
        before_action :set_ftp_user, only: %i[destroy update]
        before_action :get_websites, only: [:new]

        include ResetPasswordConcern

        def index
          response = ftp_user_api.all || []
          @ftp_users = if response[:success]
                         response[:response].response
                       else
                         []
                       end

          @windows_resources = begin
            @response = windows_api.all || []
            convert_to_mash(@response.body[:get_ftp_accounts_response][:get_ftp_accounts_result][:ftp_account])
          rescue StandardError
            []
          end
          @windows_resources = [@windows_resources].to_a.flatten
        end

        def new; end

        def create
          @response = ftp_user_api.create(resource_params)
          if @response[:success]
            set_flash
            redirect_to request.referrer
          else
            get_websites
            render :new
          end
        end

        def destroy
          @response = ftp_user_api.destroy(ftp_user_id)
          set_flash
          # redirect_to admin_sites_ftp_users_path
          redirect_to request.referrer
        end

        def update
          @response = ftp_user_api.update(ftp_user_id, resource_params)
          set_flash
          redirect_to admin_sites_ftp_users_path
        end

        private

        def ftp_user_id
          if windows?
            params[:id]
          else
            @ftp_user.isp_config_ftp_user_id
          end
        end

        def set_flash
          if @response[:success]
            flash[:success] = @response[:message]
          else
            flash.now[:error] = @response[:message]
          end
        end

        def resource_params
          if windows?
            params.require("ftp_user").permit(:username, :password).merge(get_folder_path)
          else
            params.require("ftp_user").permit(:parent_domain_id, :username, :password, :quota_size, :active, :uid, :gid,
                                              :dir)
          end
        end

        def get_folder_path
          { can_read: true, can_write: true, folder: "\\#{params[:ftp_user][:domain]}\\wwwroot" }
        end

        def windows_resource_params; end

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

        def get_websites
          response = current_spree_user.isp_config.website.all || []
          @websites = if response[:success]
                        response[:response].response
                      else
                        []
                      end
          
          @windows_sites = begin
            @windows_sites = current_spree_user.solid_cp.web_domain.all || []
            convert_to_mash(@windows_sites.body[:get_domains_response][:get_domains_result][:domain_info])
          rescue StandardError
            []
          end
        end

        def set_ftp_user
          if windows?
            # TODO: check if the ftp user id package id is belongs to current loged in user
            @ftp_user = windows_api.find(params[:id])

            # TODO: implement Decorator Pattern to decorate the ftp_user or any other resource
            @ftp_user = convert_to_mash(@ftp_user.body[:get_ftp_account_response][:get_ftp_account_result])
          else
            @ftp_user = current_spree_user.ftp_users.find_by_isp_config_ftp_user_id(params[:id])
          end

          redirect_to admin_sites_ftp_users_path, notice: 'Not Authorized' if @ftp_user.blank?
        end

        def windows?
          params[:server_type].present? && params[:server_type] == 'windows'
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

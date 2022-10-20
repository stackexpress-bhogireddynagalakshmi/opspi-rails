# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Domain controller
      class MailingListsController < Spree::Admin::BaseController
        include ResourceLimitHelper
        before_action :ensure_hosting_panel_access
        before_action :set_user_domain, only: [:new, :create, :update, :edit, :destroy]
        before_action :set_mailing_list, only: %i[edit update destroy]
        before_action -> { resource_limit_check(@user_domain.web_hosting_type,'mailing_list') }, except: [:index, :new, :update, :edit, :destroy] 
        

        def index
          response = mailing_list_api.all || []
          @mailing_lists = if response[:success]
                             response[:response].response
                           else
                             []
                           end
        end

        def new
          @mailing_list =  @user_domain.user_mailing_lists.build
        end

        def edit; end

        def create
          return @response = @limit_exceed unless @limit_exceed[:success]
          
          @response = mailing_list_api.create(mailing_list_params.merge({ domain: @user_domain.domain }), user_domain: @user_domain)

          if @response[:success]
            @mailing_list = @user_domain.user_mailing_lists.where(listname: mailing_list_params[:listname]).last 
          end
        end

        def update
          list_params  = mailing_list_params
          list_params.delete(:password) if list_params[:password] == DUMMY_PASS
          
          @response = mailing_list_api.update(@mailing_list.id, list_params)
          @mailing_list.reload
        end

        def destroy
          @response = mailing_list_api.destroy(@mailing_list.id)
        end

        private

        def mailing_list_params
          params.require("mailinglist").permit(:listname, :email, :password)
        end

        def mailing_list_api
          current_spree_user.isp_config.mailing_list
        end

        def set_mailing_list
          @mailing_list = @user_domain.user_mailing_lists.find(params[:id])

          redirect_to admin_dashboard_path, notice: 'Not Authorized' if @mailing_list .blank?
        end

      end
    end
  end
end

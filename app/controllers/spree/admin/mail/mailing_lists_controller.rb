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
          return @response = {success: false, message: I18n.t('spree.resource_limit_exceeds')} if resource_limit_exceeded("mailing_list")
          @response = mailing_list_api.create(mailing_list_params.merge({ domain: @user_domain.domain }), user_domain: @user_domain)

          if @response[:success]
            @mailing_list = @user_domain.user_mailing_lists.where(listname: mailing_list_params[:listname]).last 
          end
        end

        def update
          @response = mailing_list_api.update(@mailing_list.id, mailing_list_params)
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

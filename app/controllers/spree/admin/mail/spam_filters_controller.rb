# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Domain controller
      class SpamFiltersController < Spree::Admin::BaseController
        before_action :ensure_hosting_panel_access
        before_action :set_user_domain, only: [:new, :create, :update, :edit, :destroy]
        before_action :set_resource, only: %i[edit update destroy]

        def index
         @user_domain.user_spam_filters
        end

        def new
          @spam_filter = @user_domain.user_spam_filters.build({wb: params[:wb]})
        end

        def edit;end

        def create
          @response = isp_config_api.create(spam_filter_params, user_domain: @user_domain)

          if @response[:success]
            @spam_filter = @user_domain.user_spam_filters.by_wb_scope(spam_filter_params[:wb]).where(email: spam_filter_params[:email]).last
          end
        end

        def update
          @response = isp_config_api.update(@spam_filter.id, spam_filter_params)
          @spam_filter.reload
        end

        def destroy
          @response = isp_config_api.destroy(@spam_filter.id)
        end

        private


        def isp_config_api
          if @spam_filter&.persisted? && @spam_filter.wb == 'B' || spam_filter_params[:wb] == 'B'
            current_spree_user.isp_config.spam_filter_blacklist
          else
            current_spree_user.isp_config.spam_filter_whitelist
          end

        end

        def spam_filter_params
          params.require("spamfilter").permit(:email, :priority, :active, :wb)
                
        end

        def set_resource
          @spam_filter = @user_domain.user_spam_filters.find(params[:id])

          redirect_to admin_dashboard_path, notice: 'Not Authorized' if @spam_filter.blank?
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Domain controller
      class SpamFiltersController < Spree::Admin::BaseController
        before_action :set_resource, only: %i[edit update destroy]

        def index
          response = isp_config_api.all || []
          @resources = if response[:success]
                         response[:response].response
                       else
                         []
                       end
        end

        def new; end

        def edit
          @response = isp_config_api.find(@spam_filter.isp_config_spam_filter_id)
          @filter = @response[:response].response if @response[:success].present?
        end

        def create
          @response = isp_config_api.create(spam_filter_params)
          set_flash
          if @response[:success]
            resource_index_path
          else
            render :new
          end
        end

        def update
          @response = isp_config_api.update(@spam_filter.isp_config_spam_filter_id, spam_filter_params)
          set_flash
          if @response[:success]
            resource_index_path
          else
            render :edit
          end
        end

        def destroy
          @response = isp_config_api.destroy(@spam_filter.isp_config_spam_filter_id)
          set_flash
          resource_index_path
        end

        private

        def set_flash
          if @response[:success]
            flash[:success] = @response[:message]
          else
            flash[:error] = @response[:message]
          end
        end

        def spam_filter_params
          params.require("spamfilter").permit(:email, :priority, :active)
                .merge(filter_type_params)
        end

        def set_resource
          @spam_filter = current_spree_user.spam_filters.find_by_isp_config_spam_filter_id(params[:id])

          redirect_to resource_index_path, notice: 'Not Authorized' if @spam_filter.blank?
        end
      end
    end
  end
end

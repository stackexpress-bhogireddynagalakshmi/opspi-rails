# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Domain controller
      class MailingListsController < Spree::Admin::BaseController
        before_action :ensure_hosting_panel_access
        before_action :set_mailing_list, only: %i[edit update destroy]

        def index
          response = mailing_list_api.all || []
          @mailing_lists = if response[:success]
                             response[:response].response
                           else
                             []
                           end
        end

        def new; end

        def edit
          @response = mailing_list_api.find(@mailing_list.isp_config_mailing_list_id)
          @mailinglist = @response[:response].response if @response[:success].present?
        end

        def create
          @response = mailing_list_api.create(mail_domain_params)
          set_flash
          if @response[:success]
            redirect_to request.referrer
          else
            redirect_to request.referrer
          end
        end

        def update
          @response = mailing_list_api.update(@mailing_list.isp_config_mailing_list_id, mail_domain_params)
          set_flash
          if @response[:success]
            redirect_to admin_mail_mailing_lists_path
          else
            render :edit
          end
        end

        def destroy
          @response = mailing_list_api.destroy(@mailing_list.isp_config_mailing_list_id)
          set_flash
          redirect_to request.referrer
        end

        private

        def set_flash
          if @response[:success]
            flash[:success] = @response[:message]
          else
            flash.now[:error] = @response[:message]
          end
        end

        def mail_domain_params
          params.require("mailinglist").permit(:domain, :listname, :email, :password)
        end

        def mailing_list_api
          current_spree_user.isp_config.mailing_list
        end

        def set_mailing_list
          @mailing_list = current_spree_user.mailing_lists.find_by_isp_config_mailing_list_id(params[:id])

          redirect_to admin_mail_mailing_lists_path, notice: 'Not Authorized' if @mailing_list.blank?
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Domain controller
      class MailBoxesController < Spree::Admin::BaseController
        before_action :set_mail_box, only: %i[edit update destroy]

        def index
          response = mail_user_api.all || []
          @mailboxes = if response[:success]
                         response[:response].response
                       else
                         []
                       end
        end

        def new; end

        def edit
          @response = mail_user_api.find(@user.isp_config_mailuser_id)
          @mail_user = @response[:response].response if @response[:success].present?
        end

        def create
          mail_user_param = mail_user_params.merge({ email: formatted_email })

          @response = mail_user_api.create(mail_user_param)
          set_flash
          if @response[:success]
            redirect_to admin_mail_mail_boxes_path
          else
            render :new
          end
        end

        def update
          mail_user_param = mail_user_params.merge({ email: formatted_email })
          @response = mail_user_api.update(@user.isp_config_mailuser_id, mail_user_param)
          set_flash
          if @response[:success]
            redirect_to admin_mail_mail_boxes_path
          else
            render :edit
          end
        end

        def destroy
          @response = mail_user_api.destroy(@user.isp_config_mailuser_id)
          set_flash
          redirect_to admin_mail_mail_boxes_path
        end

        private

        def set_flash
          if @response[:success]
            flash[:success] = @response[:message]
          else
            flash[:error] = @response[:message]
          end
        end

        # mailboxes
        def mail_user_params
          params.require("mailuser").permit(:name, :login, :email, :password, :quota, :cc, :forward_in_lda, :policy, :postfix,
                                            :disablesmtp, :disabledeliver, :greylisting, :disableimap, :disablepop3)
        end

        def mail_user_api
          current_spree_user.isp_config.mail_user
        end

        def set_mail_box
          @user = current_spree_user.mail_users.find_by_isp_config_mailuser_id(params[:id])

          redirect_to admin_mail_mail_boxes_path, notice: 'Not Authorized' if @user.blank?
        end

        def formatted_email
          email = mail_user_params[:email].gsub("@", '')
          "#{email}@#{params[:mail_domain]}"
        end
      end
    end
  end
end

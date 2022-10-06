# frozen_string_literal: true

module Spree
  module Admin
    module Mail
      # Mail Domain controller
      class MailBoxesController < Spree::Admin::BaseController
        include ResourceLimitHelper
        include ResetPasswordConcern
        before_action :ensure_hosting_panel_access
        before_action :set_user_domain, only: [:new, :create, :update, :edit, :index, :destroy,:configurations]
        before_action :set_mail_box, only: %i[edit update destroy, configurations]
        before_action -> { resource_limit_check(@user_domain.web_hosting_type,'mail_box') }, except: [:show, :index, :new, :update, :edit, :destroy,:configurations] 

        def index
          @mailboxes = @user_domain.user_mailboxes.order("created_at desc")
        end

        def new
          @mailbox = UserMailbox.new
        end

        def edit; end

        def create
          return @response = @limit_exceed unless @limit_exceed[:success]

          mail_user_param = mail_user_params.merge({ email: formatted_email })
          
          @response = mail_user_api.create(mail_user_param, user_domain: @user_domain)

          if @response[:success]
            @mailbox = @user_domain.user_mailboxes.where(email: mail_user_param[:email]).last 
          end
        end

        def update
          mail_user_param = mail_user_params.merge({ email: formatted_email })
          @response = mail_user_api.update(@mailbox.id, mail_user_param)
          @mailbox.reload
        end

        def destroy
          set_mail_box #TODO; before action is not triggered somehow calling manually
          @response = mail_user_api.destroy(@mailbox.id)
        end

        def configurations; end

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
                                            :disablesmtp, :disabledeliver, :greylisting, :disableimap, :disablepop3, :mail_domain)
        end

        def mail_user_api
          current_spree_user.isp_config.mail_user
        end

        def set_mail_box
          @mailbox = @user_domain.user_mailboxes.find(params[:id])

          redirect_to admin_dashboard_path, notice: 'Not Authorized' if @mailbox .blank?
        end

        def formatted_email
          email  = mail_user_params[:email].gsub("@", '')
          domain = @user_domain.domain

          "#{email}@#{domain}"
        end
      end
    end
  end
end

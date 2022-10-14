# frozen_string_literal: true

module Spree
  module Admin
    module UsersControllerDecorator
      include UserAuthorizationConcern

      def self.prepended(base)
        base.before_action :ensure_user_authorization!, except: [:index]
        base.before_action :user_data_by_id, except: %i[create,addresses]
      end

      
      def collection
        super
        @collection = @collection.where(account_id: current_spree_user.account_id) if current_spree_user.store_admin?
        @users = @collection
      end

      ## Todo: Need to customize in callback way(here we dont have any callback)
      def update
        if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
          params[:user].delete(:password)
          params[:user].delete(:password_confirmation)
        end

        if @user.update(user_params)
          flash[:success] = Spree.t(:account_updated)
          redirect_to params.key?(:done) ? admin_users_path : edit_admin_user_path(@user)
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def addresses
        if request.put?
          if @user.update(user_params)
            flash.now[:success] = Spree.t(:account_updated)
          end
          
          params.key?(:done) ? (redirect_to admin_users_path)  : (render :addresses)
        end
      end

    def primary_key
        params[:id]
    end
    
    def user_data_by_id
      if current_user.superadmin?
        @security_info = Spree::User.find_by(id: params[:id])
      else
        @security_info = current_store.account.users.find_by(id: params[:id])
      end
      
    end
  end
end
end

if ::Spree::Admin::UsersController.included_modules.exclude?(Spree::Admin::UsersControllerDecorator)
  ::Spree::Admin::UsersController.prepend Spree::Admin::UsersControllerDecorator
end

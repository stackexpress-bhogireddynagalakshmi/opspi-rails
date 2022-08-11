# frozen_string_literal: true

module Spree
  module UserSessionsControllerDecorator
    include Tenantable

    def self.prepended(base)
      base.prepend_before_action :set_tenant
    end

    def create
      authenticate_spree_user!
  
      if spree_user_signed_in?
        respond_to do |format|
          format.html {
            flash[:success] = Spree.t(:logged_in_succesfully)
            redirect_to admin_dashboard_path
          
            # redirect_back_or_default(after_sign_in_path_for(spree_current_user))
          }
          format.js {
            user = resource.record
            render json: { ship_address: user.ship_address, bill_address: user.bill_address }.to_json
          }
        end
      else
        flash.now[:error] = t('devise.failure.invalid')
        render :new
      end
    end
  end
end

if ::Spree::UserRegistrationsController.included_modules.exclude?(::Spree::UserSessionsControllerDecorator)
  ::Spree::UserSessionsController.prepend ::Spree::UserSessionsControllerDecorator
end

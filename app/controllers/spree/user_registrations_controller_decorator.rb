# frozen_string_literal: true

module Spree
  module UserRegistrationsControllerDecorator
    # POST /resource/sign_up
    def create
    

    @user = build_resource(spree_user_params)
    resource_saved = resource.save

    yield resource if block_given?
    
    if resource_saved
        
        if  request.url == '/checkout/registration'
          sign_in(resource_name, resource)
          session[:spree_user_session] = true
          resource.send_confirmation_instructions(current_store) if Spree::Auth::Config[:confirmable]
        flash[:success] = Spree.t(:send_instructions)

        redirect_to spree.checkout_state_path(:address)
        else

          resource.send_confirmation_instructions(current_store) if Spree::Auth::Config[:confirmable]
          flash[:success] = Spree.t(:send_instructions)

          redirect_to '/login'
        end

    else
      # flash[:error] = resource.inactive_message 
    end

      if resource.persisted?
        order = Spree::Order.find_by_token(cookies.signed[:token])
        order.update_column(:user_id, resource.id) if order.present? && order.user_id.blank?
      end
      
  end



  end
end

if Spree::UserRegistrationsController.included_modules.exclude?(::Spree::UserRegistrationsControllerDecorator)
  ::Spree::UserRegistrationsController.prepend ::Spree::UserRegistrationsControllerDecorator
end

# frozen_string_literal: true

module Spree
  module UserRegistrationsControllerDecorator
    # POST /resource/sign_up
    def create
    @user = build_resource(user_sign_up_params)
    resource_saved = resource.save

    # yield resource if block_given?
    
    if resource_saved
      
      sign_in(resource_name, resource)
      session[:spree_user_session] = true
      resource.send_confirmation_instructions(current_store) if Spree::Auth::Config[:confirmable]
      flash[:success] = Spree.t(:send_instructions)
      cart = spree_current_user.orders.collect{|x| x.state == "address"}.last
      if cart
        redirect_to spree.checkout_state_path(:address)
      else
        redirect_to account_path
      end

    else
       flash[:error] = resource.inactive_message 
       render :new
    end

      if resource.persisted?
        order = Spree::Order.find_by_token(cookies.signed[:token])
        order.update_column(:user_id, resource.id) if order.present? && order.user_id.blank?
      end
      
  end

  def user_sign_up_params
    spree_user_params.merge sign_up_ip: request.ip
   end


  end
end

if Spree::UserRegistrationsController.included_modules.exclude?(::Spree::UserRegistrationsControllerDecorator)
  ::Spree::UserRegistrationsController.prepend ::Spree::UserRegistrationsControllerDecorator
end

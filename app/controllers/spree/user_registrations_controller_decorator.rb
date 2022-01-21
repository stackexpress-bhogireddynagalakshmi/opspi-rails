module Spree
  module UserRegistrationsControllerDecorator
   

    # POST /resource/sign_up
    def create
      super
      if resource.persisted?
        order = Spree::Order.find_by_token(cookies.signed[:token])
        if order.present? && order.user_id.blank?
          order.update_column(:user_id, resource.id)
        end
      end

    end

  def terms_condition
    render :terms
    # respond_to do |format|
    #   format.html
    #   format.js
    # end
    end

  end
end

::Spree::UserRegistrationsController.prepend ::Spree::UserRegistrationsControllerDecorator if Spree::UserRegistrationsController.included_modules.exclude?(::Spree::UserRegistrationsControllerDecorator)



# frozen_string_literal: true

module Spree
  module UserRegistrationsControllerDecorator
    # POST /resource/sign_up
    def create
      super
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

# frozen_string_literal: true

module Spree
  module Admin
    module StoreCreditsControllerDecorator
      include UserAuthorizationConcern
      
      def self.prepended(base)
        base.before_action :ensure_user_authorization!
      end

      def primary_key
        params[:user_id]
      end
    end
  end
end

if ::Spree::Admin::StoreCreditsController.included_modules.exclude?(Spree::Admin::StoreCreditsControllerDecorator)
  ::Spree::Admin::StoreCreditsController.prepend Spree::Admin::StoreCreditsControllerDecorator
end

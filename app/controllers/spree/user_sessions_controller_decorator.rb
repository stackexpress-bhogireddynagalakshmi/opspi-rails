# frozen_string_literal: true

module Spree
  module UserSessionsControllerDecorator
    include Tenantable

    def self.prepended(base)
      base.prepend_before_action :set_tenant
    end
  end
end

if ::Spree::UserRegistrationsController.included_modules.exclude?(::Spree::UserSessionsControllerDecorator)
  ::Spree::UserSessionsController.prepend ::Spree::UserSessionsControllerDecorator
end

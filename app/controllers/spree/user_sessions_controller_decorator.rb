module Spree
	module UserSessionsControllerDecorator
    include Tenantable
    
    def self.prepended(base)
       base.prepend_before_action :set_tenant
    end

	end
end

::Spree::UserSessionsController.prepend ::Spree::UserSessionsControllerDecorator if ::Spree::UserRegistrationsController.included_modules.exclude?(::Spree::UserSessionsControllerDecorator)



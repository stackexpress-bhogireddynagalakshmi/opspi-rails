module Spree
	module UsersControllerDecorator
		def self.prepended(base)
			base.skip_before_action :load_object
			base.before_action :load_object
		end

    def show
      super
      @orders = TenantManager::TenantHelper.unscoped_query{@user.orders.order('created_at desc')}
      @invoices = TenantManager::TenantHelper.unscoped_query{@user.invoices.order(created_at: :desc)}
    end

	end
end

::Spree::UsersController.prepend ::Spree::UsersControllerDecorator if ::Spree::UsersController.included_modules.exclude?(::Spree::UsersControllerDecorator)



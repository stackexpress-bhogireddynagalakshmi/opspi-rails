module Spree
	module Admin
	    module UsersControllerDecorator
	    	def collection	
	    	    if TenantManager::TenantHelper.current_admin_tenant? && current_spree_user.store_admin?
	    	    	super
	    	    	@collection = @collection.where(account_id: current_spree_user.tenant_service.account_id) rescue []
	    	    else
	    	    	super
	    	    end
	    	end	
	    end
	 end
end

::Spree::Admin::UsersController.prepend Spree::Admin::UsersControllerDecorator if ::Spree::Admin::UsersController.included_modules.exclude?(Spree::Admin::UsersControllerDecorator)

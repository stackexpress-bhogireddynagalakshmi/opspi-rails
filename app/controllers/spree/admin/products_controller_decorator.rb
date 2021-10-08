module Spree
	module Admin
	    module ProductsControllerDecorator
	    	def collection
		    	if TenantManager::TenantHelper.current_admin_tenant? && current_spree_user.store_admin?
		    	 	super
		    		@collection = @collection.where(account_id: current_spree_user.account_id) rescue []
		    	 else
            super
            @collection = @collection.where(account_id: params[:q][:account_id]) if params[:q][:account_id].present?		    		
		    	end
	    	end	
	    end
	end
end

::Spree::Admin::ProductsController.prepend Spree::Admin::ProductsControllerDecorator if ::Spree::Admin::ProductsController.included_modules.exclude?(Spree::Admin::ProductsControllerDecorator)



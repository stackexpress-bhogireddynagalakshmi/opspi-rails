module Spree
	module Admin
	    module UsersControllerDecorator
	    	def collection	
	    		super
	    		if  current_spree_user.store_admin?
	    			@collection = @collection.where(account_id: current_spree_user.account_id)	
	    		end
	    		@users = @collection
	    	end	
	    end
	 end
end

::Spree::Admin::UsersController.prepend Spree::Admin::UsersControllerDecorator if ::Spree::Admin::UsersController.included_modules.exclude?(Spree::Admin::UsersControllerDecorator)

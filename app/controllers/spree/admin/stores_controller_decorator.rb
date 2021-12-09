module Spree
	module Admin
	    module StoresControllerDecorator
      ## Todo: Need to customize in callback way(here we dont have any callback)
			def update
				@store.assign_attributes(permitted_store_params)
		
				if @store.save
				  flash[:success] = flash_message_for(@store, :successfully_updated)
				  redirect_to params.key?(:done) ? admin_stores_path : edit_admin_store_path(@store)
				else
				  flash[:error] = "#{Spree.t('store_errors.unable_to_update')}: #{@store.errors.full_messages.join(', ')}"
				  redirect_to spree.edit_admin_store_path(@store)
				end
			  end
	    end
	 end
end

::Spree::Admin::StoresController.prepend Spree::Admin::StoresControllerDecorator if ::Spree::Admin::StoresController.included_modules.exclude?(Spree::Admin::StoresControllerDecorator)

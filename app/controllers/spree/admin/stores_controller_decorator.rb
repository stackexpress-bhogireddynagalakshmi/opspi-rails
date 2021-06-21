module Spree
	module Admin
	    module StoresControllerDecorator
	          
	    end
	 end
end

::Spree::Admin::StoresController.prepend Spree::Admin::StoresControllerDecorator if ::Spree::Admin::StoresController.included_modules.exclude?(Spree::Admin::StoresControllerDecorator)

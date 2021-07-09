module Spree
	module UsersControllerDecorator
		def self.prepended(base)
			base.skip_before_action :load_object
			base.before_action :load_object
		end
	end
end

::Spree::UsersController.prepend ::Spree::UsersControllerDecorator if ::Spree::UsersController.included_modules.exclude?(::Spree::UsersControllerDecorator)



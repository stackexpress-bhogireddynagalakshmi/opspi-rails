module Spree
	module UserDecorator
		def self.prepended(base)
	    	base.acts_as_tenant :account
	  	end
	end
end
::Spree::User.prepend Spree::UserDecorator if ::Spree::User.included_modules.exclude?(Spree::UserDecorator)

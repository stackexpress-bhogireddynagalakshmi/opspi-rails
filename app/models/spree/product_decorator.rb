module Spree
	module ProductDecorator
		def self.prepended(base)
	    	base.acts_as_tenant :account
	    	# base.after_create_commit :update_tanent_id
	  	end


	  	# def update_tanent_id
	  	# 	   self.account_id = ActsAsTanent.current_tanent.
	  			
	  	# end


	end
end
::Spree::Product.prepend Spree::ProductDecorator if ::Spree::Product.included_modules.exclude?(Spree::ProductDecorator)


module Spree
	module ProductDecorator
		PLAN_TYPE = [['Shared Hosting','SHARED_HOSTING'],['VPS Hosting','VPS_HOSTING'],['Dedicated Hosting','DEDICATED_HOSTING']]

		def self.prepended(base)
	    	base.acts_as_tenant :account
	  	end
	end
end

::Spree::Product.prepend Spree::ProductDecorator if ::Spree::Product.included_modules.exclude?(Spree::ProductDecorator)



[:plan_type,:subscribable,:no_of_website,:storage,:ssl_support,:domain,:subdomain,:parked_domain,:mailbox,:auto_daily_malware_scan,:email_order_confirmation].each do |field|
	Spree::PermittedAttributes.product_attributes.push << field
end



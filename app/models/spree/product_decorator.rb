
module Spree
	module ProductDecorator
		PLAN_TYPE = [['Shared Hosting','SHARED_HOSTING'],['VPS Hosting','VPS_HOSTING'],['Dedicated Hosting','DEDICATED_HOSTING']].freeze

		def self.prepended(base)
	    	base.acts_as_tenant :account
	    	base.has_many :susbscriptions,:class_name=>'Subscription'
	    	# base.before_update :ensure_no_active_subscription, if: :deleted_at_changed?
	  	end


	  	# def ensure_no_active_subscription
	   #    if susbscriptions.active.present?
	   #      errors.add(:base, "You can not delete a plan with active subscriptions")
	   #      throw :abort
	   #    end
	   #  end
	end
end

::Spree::Product.prepend Spree::ProductDecorator if ::Spree::Product.included_modules.exclude?(Spree::ProductDecorator)


[:plan_type,:subscribable,:no_of_website,:storage,:ssl_support,:domain,:subdomain,:parked_domain,:mailbox,:auto_daily_malware_scan,:email_order_confirmation].each do |field|
	Spree::PermittedAttributes.product_attributes.push << field
end



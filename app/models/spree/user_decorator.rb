module Spree
	module UserDecorator
		def self.prepended(base)
	    	base.acts_as_tenant :account
	    	base.has_many :susbscription,:class_name=>'Subscription'
	    	base.has_one :active_susbscription,->{where(active: true)},:class_name=>'Subscription'
	  	end
	end
end
::Spree::User.prepend Spree::UserDecorator if ::Spree::User.included_modules.exclude?(Spree::UserDecorator)

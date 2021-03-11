module Spree
	module UserDecorator
		def self.prepended(base)
	    	base.acts_as_tenant :account,:class_name=>'Account'
	    	base.has_many :susbscriptions,:class_name=>'Subscription'
	    	base.has_many :plans,through: :susbscriptions,:class_name=>'Spree::Product' 
	    	base.has_one :shared_hosting,->{joins(:plans).where(:plan_type=>'SHARED_HOSTING')}, :class_name=>'Subscription'
	  	end

	  	def superadmin?
	  		self.has_spree_role?('admin')
	  	end

	end
end
::Spree::User.prepend Spree::UserDecorator if ::Spree::User.included_modules.exclude?(Spree::UserDecorator)

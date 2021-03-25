module Spree
	module UserDecorator
		def self.prepended(base)
	    	base.acts_as_tenant :account,:class_name=>'Account'
	    	base.has_many :susbscriptions,:class_name=>'Subscription'
	    	base.has_many :plans,through: :susbscriptions,:class_name=>'Spree::Product' 
	    	base.has_one :shared_hosting,->{joins(:plans).where(:plan_type=>'SHARED_HOSTING')}, :class_name=>'Subscription'
	    	base.after_commit :add_to_solid_cp, on: [:create]
	  	end

	  	def superadmin?
	  		self.has_spree_role?('admin')
	  	end

	  	def solid_cp
	  		@solid_cp ||= SolidCp::User.new(self)
	  	end

	  	def add_to_solid_cp
	  		set_solid_cp_credentials
	  		solid_cp.add_user if SolidCp::Config.register_users 
	  	end

	  	def set_solid_cp_credentials
	  		self.solid_cp_password = SolidCp::Misc.password_generator
      		save!
	  	end
	end
end
::Spree::User.prepend Spree::UserDecorator if ::Spree::User.included_modules.exclude?(Spree::UserDecorator)
Spree::PermittedAttributes.user_attributes.push << :first_name
Spree::PermittedAttributes.user_attributes.push << :last_name



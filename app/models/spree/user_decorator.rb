module Spree
	module UserDecorator

		def self.prepended(base)
	    	base.acts_as_tenant :account,:class_name=>'::Account'
	    	base.has_many :susbscriptions,:class_name=>'Subscription'
	    	base.has_many :plans,through: :susbscriptions,:class_name=>'Spree::Product' 
	    	base.has_many :packages,:class_name=>'Package'
	    	base.has_one :spree_store,:through=>:account,:class_name=>'Spree::Store' 
	    	base.has_one :shared_hosting,->{joins(:plans).where(:plan_type=>'SHARED_HOSTING')}, :class_name=>'Subscription'
	    	base.after_commit :add_to_solid_cp, on: [:create]
	    	base.after_commit :add_to_isp_config, on: [:create]
	  	end

	  	def superadmin?
	  		self.has_spree_role?('admin')
	  	end

	  	def store_admin?
	  		self.has_spree_role?('store_admin')
	  	end

	  	def solid_cp
	  		@solid_cp ||= SolidCp::User.new(self)
	  	end

	  	def isp_config
	  		@solid_cp ||= IspConfig::User.new(self)
	  	end

	  	def add_to_solid_cp	  	
	  		SolidCpProvisioningJob.set(wait: 3.second).perform_later(self.id)
	  	end

	  	def add_to_isp_config	  	
	  		IspConfigProvisioningJob.set(wait: 3.second).perform_later(self.id)
	  	end


	  	# Solid CP Concerns
	  	def company_name
	  		account.orgainization_name
	  	end

	  	def full_name
	  		"#{first_name} #{last_name}"
	  	end


	  	#for store admin or reseller owner_id will be always 1
	  	#For normal user ower_id will be the is of Store Admin/Reseller
	  	def owner_id
	  		if self.store_admin?
	  			1
	  		else
	  			account.store_admin.try(:solid_cp_id) || 1
	  		end
	  	end


	  	def reseller_id
	  		if self.store_admin?
	  			0
	  		else
	  			account.store_admin.try(:isp_config_id) || 0
	  		end
	  	end

	end
end
::Spree::User.prepend Spree::UserDecorator if ::Spree::User.included_modules.exclude?(Spree::UserDecorator)
Spree::PermittedAttributes.user_attributes.push << :first_name
Spree::PermittedAttributes.user_attributes.push << :last_name



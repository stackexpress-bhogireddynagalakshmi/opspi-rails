module Spree
	module UserDecorator
		attr_accessor :subdomain,:business_name

		def self.prepended(base)
	    	base.acts_as_tenant :account,:class_name=>'::Account'
	    	base.before_create :ensure_unique_subdomain

	    	base.has_many :susbscriptions,:class_name=>'Subscription'
	    	base.has_many :plans,through: :susbscriptions,:class_name=>'Spree::Product' 
	    	base.has_many :packages,:class_name=>'Package'
	    	base.has_one :spree_store,:through=>:account,:class_name=>'Spree::Store' 
	    	base.has_one :tenant_service

	    	base.after_commit :ensure_tanent_exists, on: [:create]
	    	base.after_commit :provision_accounts, on: [:create]
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
	  		@isp_config ||= IspConfig::User.new(self)
	  	end

	  	def ensure_tanent_exists
	  		if  self.reseller_signup? && TenantManager::TenantHelper.current_admin_tenant?
	  			StoreManager::StoreCreator.new(self).call
	  		end
	  	end

	  	def provision_accounts
	  		AppManager::AccountProvisioner.new(self.reload).call
	  	end


	  	# Solid CP Concerns
	  	def company_name
	  		account&.orgainization_name
	  	end

	  	def full_name
	  		"#{first_name} #{last_name}"
	  	end

	  	#for store admin or reseller owner_id will be always 1
	  	#For normal user ower_id will be the is of Store Admin/Reseller
	  	def owner_id
	  		self.store_admin? ? 1  : (account.store_admin.try(:solid_cp_id) || 1)
	  	end

	  	def reseller_id
	  		self.store_admin? ? 0 : (account&.store_admin.try(:isp_config_id) || 0)
	  	end


	  	def ensure_unique_subdomain
	  		if self.reseller_signup? && ::Account.where(subdomain: subdomain).size > 0
	  			errors.add(:subdomain, 'is already taken')
	  			throw :abort
	  		end
	  	end
	end
end

::Spree::User.prepend Spree::UserDecorator if ::Spree::User.included_modules.exclude?(Spree::UserDecorator)
Spree::PermittedAttributes.user_attributes.push << :first_name
Spree::PermittedAttributes.user_attributes.push << :last_name
Spree::PermittedAttributes.user_attributes.push << :subdomain
Spree::PermittedAttributes.user_attributes.push << :reseller_signup
Spree::PermittedAttributes.user_attributes.push << :business_name






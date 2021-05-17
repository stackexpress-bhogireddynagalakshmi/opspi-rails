module Spree
	module StoreDecorator
	  attr_accessor :admin_password,:solid_cp_password,:isp_config_username,:isp_config_password,:isp_config_access,:solid_cp_access
	 
	  def self.prepended(base)  
	    base.after_commit :create_account_and_admin_user, on: [:create,:update]
	    base.acts_as_tenant :account,class_name: '::Account'
	    base.validates :url, uniqueness: true
	    base.validates_format_of :admin_email, with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	    base.validates :isp_config_username,
	    exclusion: { in: %w(www mail ftp smtp imap download upload image service offline online admin root username webmail blog help support),message: "%{value} is not a valid username." }
	  end

	  protected
	  	def create_account_and_admin_user
	  		ActiveRecord::Base.transaction do

			    account = TenantManager::TenantCreator.new(self).call

		        ::TenantManager::StoreTenantUpdater.new(self,account.id).call

		        StoreManager::StoreAdminCreator.new(self,account: account).call

		    end
	  	end

	end
end

::Spree::Store.prepend ::Spree::StoreDecorator if ::Spree::Store.included_modules.exclude?(::Spree::StoreDecorator)

[:admin_email,:admin_password,:solid_cp_access,:solid_cp_password,:solid_cp_master_plan_id,:isp_config_access,:isp_config_username,:isp_config_password].each do |attr|
	Spree::PermittedAttributes.store_attributes.push << attr
end

module Spree
	module StoreDecorator
	  attr_accessor :admin_password,:solid_cp_password,:isp_config_username,:isp_config_password,:isp_config_access,:solid_cp_access
	 
	  def self.prepended(base)  
	    base.after_commit :create_account_and_admin_user, on: [:create,:update]
	    base.acts_as_tenant :account,class_name: '::Account'
	    base.validates :url, uniqueness: true
	    base.validates_format_of :admin_email, with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	    # base.delegate :isp_config_access, to: :account
	    # base.delegate :solid_cp_access, to: :account
	  end

	  protected
	  	def create_account_and_admin_user
	  		ActiveRecord::Base.transaction do
		      	email =  self.admin_email
		     	password = self.admin_password
		      	account = ::Account.find_or_create_by({:store_id=>self.id})

			    account.update({
			      	:orgainization_name=>self.name,
			      	:domain=> self.url,
			      	:subdomain=> self.url,
			      	:solid_cp_access => self.solid_cp_access,
			      	:isp_config_access => self.isp_config_access
			    })

		        self.update_column :account_id, account.id
		   
		        admin = Spree::User.find_by({email: email})		

		       	admin = Spree::User.create({email: email,:password=>password,:password_confirmation=>password}) if admin.blank?

		       	Sidekiq.redis{|conn|conn.set("spree_user_id_#{admin.id}_solid_cp", solid_cp_password)} if solid_cp_password.present?

		        admin.update(:login => email,
	                :account_id => account.id)

		        role = Spree::Role.find_or_create_by({:name=>'store_admin'})
		        admin.spree_roles << role if !admin.spree_roles.include?(role)
		        admin.save

		    end
	  	end

	end
end

::Spree::Store.prepend ::Spree::StoreDecorator if ::Spree::Store.included_modules.exclude?(::Spree::StoreDecorator)
Spree::PermittedAttributes.store_attributes.push << :admin_email
Spree::PermittedAttributes.store_attributes.push << :admin_password
Spree::PermittedAttributes.store_attributes.push << :solid_cp_password
Spree::PermittedAttributes.store_attributes.push << :solid_cp_master_plan_id
Spree::PermittedAttributes.store_attributes.push << :isp_config_username
Spree::PermittedAttributes.store_attributes.push << :isp_config_password





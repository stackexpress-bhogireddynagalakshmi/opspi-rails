module Spree
	module StoreDecorator
	  attr_accessor :admin_password
	  def self.prepended(base)
	     
	    base.after_commit :create_account_and_admin_user, on: [:create,:update]
	    # base.after_commit :provision_hosting_space,on: :create

	    base.acts_as_tenant :account,class_name: '::Account'
	    base.validates :url, uniqueness: true

	  end

	  protected
	  	def create_account_and_admin_user
	  		ActiveRecord::Base.transaction do
		      	email =  self.admin_email
		     	password = self.admin_password
		      	account = ::Account.find_or_create_by({:store_id=>self.id })

			    account.update({
			      	:orgainization_name=>self.name,
			      	:domain=> self.url,
			      	:subdomain=> self.url,
			    })

		       self.update_column :account_id, account.id
		     

		        admin = Spree::User.find_by({email: email})		

		       	admin = Spree::User.create({email: email,:password=>password,:password_confirmation=>password}) if admin.blank?
 	
		        admin.update(:login => email,
	                :account_id => account.id)

		        role = Spree::Role.find_or_create_by({:name=>'store_admin'})
		        admin.spree_roles << role if !admin.spree_roles.include?(role)
		        admin.save

		    end
	  	end

	  	# def provision_hosting_space
	  	# 	admin = Spree::User.find_by({email: email})
	  	# end
	end
end

::Spree::Store.prepend ::Spree::StoreDecorator if ::Spree::Store.included_modules.exclude?(::Spree::StoreDecorator)
Spree::PermittedAttributes.store_attributes.push << :admin_email
Spree::PermittedAttributes.store_attributes.push << :admin_password
Spree::PermittedAttributes.store_attributes.push << :solid_cp_master_plan_id


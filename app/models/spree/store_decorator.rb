module Spree
	module StoreDecorator
	  def self.prepended(base)
	    base.after_commit :create_account_and_admin_user, on: [:create, :update]
	    base.acts_as_tenant :account
	    base.validates :url, uniqueness: true
	  end

	  protected

	  	def create_account_and_admin_user
	  		ActiveRecord::Base.transaction do
		      email =  self.admin_email
		      password = "admin#123"

		      account = ::Account.find_or_create_by({:orgainization_name=>self.name,
		      	:store_id=>self.id
		      	
		      })

		      account.update({
		      	:domain=> self.url,
		      	:subdomain=> self.url,
		      })

		      self.account_id = account.id
		      self.save

		      unless Spree::User.find_by_email(email)
		        admin = Spree::User.create(:password => password,
		                            :password_confirmation => password,
		                            :email => email,
		                            :login => email,
		                            :account_id => account.id)
		        role = Spree::Role.find_or_create_by({:name=>'admin'})
		        admin.spree_roles << role
		        admin.save


		      end
		    end
		   
	  	end
	end
end

::Spree::Store.prepend ::Spree::StoreDecorator if ::Spree::Store.included_modules.exclude?(::Spree::StoreDecorator)
Spree::PermittedAttributes.store_attributes.push << :admin_email


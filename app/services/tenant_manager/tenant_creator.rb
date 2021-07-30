module TenantManager
	class TenantCreator
		attr_reader :store

		def initialize(store,options = {})
  			@store = store
  		end

  		def call
  			account = ::Account.find_or_create_by({:store_id=>store.id})

		    account.update({
	      	:orgainization_name=>store.name,
	      	:domain=> store.url,
	      	:solid_cp_access => store.solid_cp_access,
	      	:isp_config_access => store.isp_config_access
		    })
		    
       account.update_column :subdomain,store.url if account.subdomain.blank?
       
		   account
  		end
	end
end
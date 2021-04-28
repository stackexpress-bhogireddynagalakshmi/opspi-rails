class ApplicationController < ActionController::Base
	set_current_tenant_by_subdomain_or_domain(:account, :subdomain,:domain)

	before_action do
	 	if DomainCheck.check_domain(request)
	 		ActsAsTenant.current_tenant = Account.where('subdomain = ? or domain = ?',request.host,request.host).first 
	 		ActsAsTenant.current_tenant = nil if current_spree_user&.superadmin?
	 	else
	 	 	render :json=>'Sorry, this domain is currently unavailable.'
	 	end
	end

	private

	class DomainCheck
		def self.check_domain request
			whitelisted_domains = Spree::Store.pluck(:url) + Spree::Store::RESERVED_URL
		    whitelisted_domains.include? (request.host)
		end
	end
		
end

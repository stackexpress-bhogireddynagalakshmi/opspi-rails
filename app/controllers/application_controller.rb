class ApplicationController < ActionController::Base
	 set_current_tenant_by_subdomain_or_domain(:account, :subdomain,:domain)

	 before_action do
	 	 if DomainCheck.check_domain(request)
	 		ActsAsTenant.current_tenant = Account.where('subdomain = ? or domain = ?',request.host,request.host).first
	 	 else
	 	 	render :json=>'Sorry, this domain is currently unavailable.'
	 	 end
	 end

	private

	class DomainCheck
		def self.check_domain request
			whitelisted_domains = Account.pluck(:subdomain) + Account.pluck(:domain)
			whitelisted_domains << 'test01.dev.opspi.com'
			whitelisted_domains << 'localhost'
		    whitelisted_domains.include? (request.host)
		end
	end
end

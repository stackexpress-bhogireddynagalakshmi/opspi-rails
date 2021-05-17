class ApplicationController < ActionController::Base
	set_current_tenant_by_subdomain_or_domain(:account, :subdomain,:domain)

	helper_method [:get_tenant_host_for_resource_path]


	before_action do
	 	if DomainCheck.check_domain(request)
	 		ActsAsTenant.current_tenant = Account.where('subdomain = ? or domain = ?',request.host,request.host).first 
	 		ActsAsTenant.current_tenant = nil if current_spree_user&.superadmin?
	 	else
	 	 	render :json=>'Sorry, this domain is currently unavailable.'
	 	end
	end

    

	# def after_sign_in_path_for(resource)
	# 	byebug
	# 	tenant_service = TenantManager::TenantServiceExecutor.new(current_spree_user).call

	# 	if tenant_service.present? && tenant_service.service_executed
	# 		redirect_to get_tenant_host_for_resource_path(current_spree_user) 
	# 	end
	# end


	def get_tenant_host_for_resource_path(resource)
	  	[request.protocol,resource.account.domain,":#{request.port}"].join
	end

	
	private

	class DomainCheck
		def self.check_domain request
			whitelisted_domains = Spree::Store.pluck(:url) + [OpspiHelper.admin_domain]
		    whitelisted_domains.include? (request.host)
		end
	end


end




class ApplicationController < ActionController::Base
	 set_current_tenant_by_subdomain_or_domain(:account, :subdomain,:domain)
	 
	 before_action do

	 	ActsAsTenant.current_tenant = Account.where('subdomain = ? or domain = ?',request.host,request.host).first
	 end

	#  ActiveSupport.on_load(:application_controller) do |base|
	#  	byebug
	#   base.extend ActsAsTenant::ControllerExtensions
	#   base.include ActsAsTenant::TenantHelper
	# end

end

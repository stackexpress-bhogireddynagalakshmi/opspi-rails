class ApplicationController < ActionController::Base
	set_current_tenant_by_subdomain_or_domain(:account, :subdomain,:domain)

	helper_method [:get_tenant_host_for_resource_path]

	include Tenantable

	before_action do
    set_tenant
  end

end




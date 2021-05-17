module ApplicationHelper

	def get_spree_roles(user)
		if user.superadmin?
			Spree::Role.all
		elsif user.store_admin?
			Spree::Role.where(name: ['user'])
		end
	end

	def current_admin_tenant?
		TenantManager::TenantHelper.current_admin_tenant?
	end

	def render_new_tenant_information(order)
		if current_admin_tenant?
			user = TenantManager::TenantHelper.unscoped_query{order.user}
			text = "Your store created successfully. <br/>"
	        text+=link_to user.account.domain,get_tenant_host_for_resource_path(user), target: '_blank'
	    end
	end
end

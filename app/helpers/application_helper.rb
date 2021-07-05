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
		text = ""
		if current_admin_tenant?
			user = TenantManager::TenantHelper.unscoped_query{order.user}
	        text+=link_to user.account.domain,get_tenant_host_for_resource_path(user), target: '_blank'
	    end
	end

	def plan_type_values(user)
		if user.superadmin?
			Spree::Product::server_types.keys
		elsif user.store_admin?
			TenantManager::TenantHelper.unscoped_query{current_spree_user.orders.collect{|o|o.products.pluck(:server_type)}.flatten}.uniq
		end
	end
end

module ApplicationHelper

	def get_spree_roles(user)

		if user.superadmin?
			Spree::Role.all
		elsif user.store_admin?
			Spree::Role.where(name: ['user'])
		end
	end
end

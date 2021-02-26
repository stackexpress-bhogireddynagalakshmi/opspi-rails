module OpsPi
	module Spree
		module AbilityDecorator
		  def abilities_to_register
		    [StoreAdminAbility]
		  end
		end
	end
end
::Spree::Ability.prepend(OpsPi::Spree::AbilityDecorator)

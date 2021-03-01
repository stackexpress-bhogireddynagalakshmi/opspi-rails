
	module Spree
		module AbilityDecorator
		  def abilities_to_register
		    [StoreAdminAbility]
		  end
		end
	end

::Spree::Ability.prepend(Spree::AbilityDecorator)


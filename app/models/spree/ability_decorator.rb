# frozen_string_literal: true

module Spree
  module AbilityDecorator
    def abilities_to_register
      [StoreAdminAbility, UserAbility]
    end
  end
end

::Spree::Ability.prepend(Spree::AbilityDecorator)

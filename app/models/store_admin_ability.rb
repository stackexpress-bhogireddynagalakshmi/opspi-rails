class StoreAdminAbility
	include CanCan::Ability

	def initialize(user)
      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('store_admin')
      	 apply_store_admin_permissions(user)
      end
    end

    def apply_store_admin_permissions(user)

    	can :manage, ::Spree::Order
    	can :manage, ::Spree::Product
    	can :manage, ::Spree::User
    	
    	# can :manage, ::Spree::ReturnAuthorization
    	# can :manage, ::Spree::CustomerReturn
    	can :manage, ::Spree::Admin::ReportsController
    	can :manage, ::Spree::Promotion


    	can :read, ::Spree::Country
	    can :read, ::Spree::OptionType
	    can :read, ::Spree::OptionValue
    	can :read, ::Spree::State
	    can :read, ::Spree::Store
	    can :read, ::Spree::Taxon
	    can :read, ::Spree::Taxonomy
	    can :read, ::Spree::Variant
	    can :read, ::Spree::Zone
    end

end
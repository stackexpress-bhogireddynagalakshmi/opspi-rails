class StoreAdminAbility
  include CanCan::Ability

  def initialize(user)
      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('store_admin')
         apply_store_admin_permissions(user)
      end
    end

    def apply_store_admin_permissions(user)

      can :manage, ::Spree::Order   #unless TenantManager::TenantHelper.current_admin_tenant?
      can :manage, ::Spree::Product unless TenantManager::TenantHelper.current_admin_tenant?
      can :manage, ::Spree::User    unless TenantManager::TenantHelper.current_admin_tenant?
      can :manage, ::Spree::Image 
      can :manage, ::Spree::Variant
      can :manage, ::Spree::ProductProperty
      can :manage, ::Spree::StockItem
      can :manage, ::Spree::StockLocation unless TenantManager::TenantHelper.current_admin_tenant?
      can :manage, ::Spree::StockMovement
      can :manage, ::Spree::Price
      
      #can :manage, ::Spree::ReturnAuthorization
      #can :manage, ::Spree::CustomerReturn
      #can :manage, ::Spree::Admin::ReportsController
      #can :manage, ::Spree::Promotion
      
      can :manage, :domain_registrations
      can :manage, :isp_config
      can :manage, :domains
      can :manage, :my_store
      can :manage, ::Spree::PaymentMethod unless TenantManager::TenantHelper.current_admin_tenant?
      can :admin, ::Spree::Store if TenantManager::TenantHelper.current_tenant.present? && TenantManager::TenantHelper.current_tenant.id == user.account_id


      can :manage, ::Spree::Payment  
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
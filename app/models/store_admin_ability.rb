class StoreAdminAbility
  include CanCan::Ability

  def initialize(user)
    apply_store_admin_permissions(user) if user.respond_to?(:has_spree_role?) && user.has_spree_role?('store_admin')
  end

  def apply_store_admin_permissions(user)
    can :manage, ::Spree::Order # unless TenantManager::TenantHelper.current_admin_tenant?
    can :manage, ::Spree::Product unless TenantManager::TenantHelper.current_admin_tenant?
    can :manage, ::Spree::User    unless TenantManager::TenantHelper.current_admin_tenant?
    can :manage, ::Spree::Image
    can :manage, ::Spree::Variant
    can :manage, ::Spree::ProductProperty
    can :manage, ::Spree::StockItem
    can :manage, ::Spree::StockLocation unless TenantManager::TenantHelper.current_admin_tenant?
    can :manage, ::Spree::StockMovement
    can :manage, ::Spree::Price
    
    can :manage, :domain_registrations

    # Removing hosting control access for store admin as of May 9 2022
    # can :manage, :domains
    # can :manage, :mail_boxes
    # can :manage, :mailing_lists
    # can :manage, :spam_filter_blacklists
    # can :manage, :spam_filter_whitelists
    # can :manage, :hosted_zones
    # can :manage, :hosted_zone_records
    # can :manage, :websites
    # can :manage, :ftp_users
    # can :manage, :forwards
    # can :manage, :sub_domains
    # can :manage, :wizards
    # can :manage, :protected_folders
    # can :manage, :protected_folder_users
    # can :manage, :statistics


    can :manage, :my_store
    can :manage, ::Spree::PaymentMethod unless TenantManager::TenantHelper.current_admin_tenant?
    if TenantManager::TenantHelper.current_tenant.present? && TenantManager::TenantHelper.current_tenant.id == user.account_id
      can :admin,
          ::Spree::Store
    end

    can :manage, :bookkeeping_documents

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

class UserAbility
  include CanCan::Ability

  def initialize(user)
    apply_user_permissions(user) if user.respond_to?(:has_spree_role?) && user.has_spree_role?('user')
  end

  def apply_user_permissions(user)
    can :read,   :orders
    can :manage, :user_domains
    can :manage, :domain_registrations
    can :manage, :domains
    can :manage, :mail_boxes
    can :manage, :mailing_lists
    can :manage, :spam_filters
    can :manage, :spam_filter_blacklists
    can :manage, :spam_filter_whitelists
    can :manage, :hosted_zones
    can :manage, :hosted_zone_records
    can :manage, :websites
    can :manage, :ftp_users
    can :manage, :forwards
    can :manage, :sub_domains
    can :manage, :wizards
    can :manage, :protected_folders
    can :manage, :protected_folder_users
    can :manage, :site_builders
    can :manage, :isp_databases
    can :manage, :my_account_profiles
    can :manage, :my_account_invoices
    can :manage, :my_account_orders
    can :manage, :my_account_subscriptions
    can :manage, :dashboard
  end
end

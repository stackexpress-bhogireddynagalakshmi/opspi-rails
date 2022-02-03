class UserAbility
  include CanCan::Ability

  def initialize(user)
      if user.respond_to?(:has_spree_role?) && user.has_spree_role?('user')
         apply_user_permissions(user)
      end
    end

    def apply_user_permissions(user)
      can :read, :orders
      can :manage, :domain_registrations
      can :manage, :domains
      can :manage, :mail_boxes
      can :manage, :mailing_lists
      can :manage, :hosted_zones
      can :manage, :hosted_zone_records
      can :manage, :websites
    end
end

# frozen_string_literal: true

class UserAbility
  include CanCan::Ability

  def initialize(user)
    apply_user_permissions(user) if user.respond_to?(:has_spree_role?) && user.has_spree_role?('user')
  end

  def apply_user_permissions(_user)
    can :read, :orders
    can :manage, :domain_registrations
    can :manage, :domains
    can :manage, :mail_boxes
    can :manage, :mailing_lists
    can :manage, :hosted_zones
    can :manage, :hosted_zone_records
    can :manage, :websites
    can :manage, :ftp_users
  end
end

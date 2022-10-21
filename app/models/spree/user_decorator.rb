# frozen_string_literal: true


module Spree
  module UserDecorator
    attr_accessor :subdomain, :business_name
    
    def self.prepended(base)
      base.validate :ensure_valid_store_params, on: [:create]

      base.belongs_to :account, class_name: '::Account'
      base.has_many :subscriptions, class_name: 'Subscription'
      base.has_many :plans, through: :subscriptions, class_name: 'Spree::Product'
      base.has_many :packages, class_name: 'Package'
      base.has_many :invoices
      base.has_one :spree_store, through: :account, class_name: 'Spree::Store'
      base.has_one :tenant_service
      base.has_one :user_key
      base.has_many :mail_domains
      base.has_many :mail_users
      base.has_many :mailing_lists
      base.has_many :spam_filters
      base.has_many :hosted_zones
      base.has_many :websites
      base.has_many :ftp_users
      base.has_many :sub_domains
      base.has_many :mail_forwards
      base.has_many :protected_folders
      base.has_many :protected_folder_users
      base.has_many :isp_databases
      base.has_many :user_domains
      base.has_many :user_databases

      base.after_commit :after_create_callbacks, on: [:create]
      base.accepts_nested_attributes_for :user_key, reject_if: :reject_if_key_blank
    end

    def superadmin?
      has_spree_role?('admin')
    end

    def store_admin?
      has_spree_role?('store_admin')
    end

    def end_user?
      has_spree_role?('user')
    end

    def user_role
      if store_admin?
        'Reseller'
      elsif end_user?
        'User'
      end
    end

    def solid_cp
      @solid_cp ||= SolidCp::User.new(self)
    end

    def isp_config
      @isp_config ||= IspConfig::User.new(self)
    end

    def chat_woot
      @chat_woot ||= ChatWoot::ChatWootInbox.new(self)
    end

    def company_name
      account&.orgainization_name
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    # for store admin or reseller owner_id will be always 1
    # For normal user ower_id will be the is of Store Admin/Reseller
    def owner_id
      store_admin? ? 1 : (account.store_admin.try(:solid_cp_id) || 1)
    end

    def reseller_id
      store_admin? ? 0 : (account&.store_admin.try(:isp_config_id) || 0)
    end

    def send_devise_notification(notification, *args)
      UserMailer.send(notification, self, *args).deliver_later
    end

    def ensure_valid_store_params
      return unless reseller_signup?

      unless subdomain.match?(/^[a-z0-9]*?$/) # alphanumeric
        errors.add(:base,
                   'Subdomain is invalid. Please enter valid subdomain containing lowercase characters and numbers only.')
      end

      store = StoreManager::StoreCreator.new(self).store
      return nil if store.valid?

      errors.merge!(store.errors)
    end

    def active_for_authentication?
      if superadmin?
        super && TenantManager::TenantHelper.current_admin_tenant? || TenantManager::TenantHelper.current_tenant.blank?
      elsif store_admin?
        if TenantManager::TenantHelper.current_admin_tenant?
          super
        else
          super && account_id == TenantManager::TenantHelper.current_tenant_id
        end
      else
        super && account_id == TenantManager::TenantHelper.current_tenant_id
      end
    end

    def marketplace_url
      if store_admin?
        get_subdomain_from_redis
      else
        account.spree_store.url
      end
    end

    def get_subdomain_from_redis
      return unless reseller_signup?

      AppManager::RedisWrapper.get(reseller_subdomain_redis_key) || account.spree_store.url
    end

    def reseller_subdomain_redis_key
      "reseller_id_#{id}_domain"
    end

    def inactive_message
      return super unless confirmed?

      I18n.t("spree.invalid_tenant")
    end

    def reseller_club_password_key
      "reseller_club_user_id_#{id}"
    end

    def reject_if_key_blank(attrs)
      attrs['reseller_club_account_key_enc'].blank? && attrs['reseller_club_account_id'].blank?
    end

    def have_linux_access?
      get_purchased_plans.include?('linux')
    end

    def have_windows_access?
      get_purchased_plans.include?('windows')
    end

    def have_hsphere_access?
      get_purchased_plans.include?('hsphere')
    end

    def have_reseller_plan?
      get_purchased_plans.include?('reseller_plan')
    end

    def get_purchased_plans
      TenantManager::TenantHelper.unscoped_query do
        orders.where(payment_state: 'paid').collect do |o|
          o.products.pluck(:server_type)
        end.flatten
      end
    end

    def after_create_callbacks
      ensure_user_tenant_updated
      add_terms_and_conditions
      ensure_reseller_store_created
      save_subdomain_to_redis
      ensure_panel_config_set
    end

    #  after create Callbacks methods
    def ensure_user_tenant_updated
      tenant_id =
        if TenantManager::TenantHelper.current_admin_tenant? || TenantManager::TenantHelper.current_tenant.blank?
          TenantManager::TenantHelper.admin_tenant_id
        else
          TenantManager::TenantHelper.current_tenant_id
        end

      ActsAsTenant.without_tenant { update_column :account_id, tenant_id }
    end

    def add_terms_and_conditions
      terms_and_conditions = true
    end

     def ensure_reseller_store_created
      if reseller_signup? && TenantManager::TenantHelper.current_admin_tenant?
        StoreManager::StoreCreator.new(self).call
      elsif spree_roles.blank?
        StoreManager::StoreAdminRoleAssignor.new(self, { role: "user" }).call
      end
    end

    def save_subdomain_to_redis
      return unless reseller_signup?

      url = "#{subdomain}.#{ENV['BASE_DOMAIN']}"

      AppManager::RedisWrapper.set(reseller_subdomain_redis_key, url)
    end

    def ensure_panel_config_set
      return nil unless panel_config.blank?

      self.panel_config = ActivePanel.panel_configs_json
      self.save
    end

    # end  after create callbacks

  end
end

::Spree::User.prepend Spree::UserDecorator if ::Spree::User.included_modules.exclude?(Spree::UserDecorator)
Spree::PermittedAttributes.user_attributes.push << :first_name
Spree::PermittedAttributes.user_attributes.push << :last_name
Spree::PermittedAttributes.user_attributes.push << :subdomain
Spree::PermittedAttributes.user_attributes.push << :reseller_signup
Spree::PermittedAttributes.user_attributes.push << :business_name
Spree::PermittedAttributes.user_attributes.push << :terms_and_conditions
Spree::PermittedAttributes.user_attributes.push << :sign_up_ip

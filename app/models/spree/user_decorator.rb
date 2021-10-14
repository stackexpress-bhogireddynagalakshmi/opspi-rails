module Spree
  module UserDecorator
    attr_accessor :subdomain,:business_name

    def self.prepended(base)
      base.validate :ensure_valid_store_params,on: [:create]
      base.belongs_to :account,:class_name=>'::Account'
      base.has_many :subscriptions,:class_name=>'Subscription'
      base.has_many :plans,through: :subscriptions,:class_name=>'Spree::Product' 
      base.has_many :packages,:class_name=>'Package'
      base.has_many :invoices
      base.has_one :spree_store,:through=>:account,:class_name=>'Spree::Store' 
      base.has_one :tenant_service

      base.after_commit :update_user_tanent, on: [:create]
      base.after_commit :ensure_tanent_exists, on: [:create]
      base.after_commit :provision_accounts, on: [:create]
      base.after_commit :save_subdomain_to_redis, on: [:create]
    end

    def superadmin?
      self.has_spree_role?('admin')
    end

    def store_admin?
      self.has_spree_role?('store_admin')
    end
    
    def solid_cp
      @solid_cp ||= SolidCp::User.new(self)
    end

    def isp_config
      @isp_config ||= IspConfig::User.new(self)
    end

    def ensure_tanent_exists
      update_user_tanent
      if self.reseller_signup? && TenantManager::TenantHelper.current_admin_tenant?
        StoreManager::StoreCreator.new(self).call
      else
        StoreManager::StoreAdminRoleAssignor.new(self,{role: "user"}).call
      end
    end

    def provision_accounts
      AppManager::AccountProvisioner.new(self.reload).call
    end

    def company_name
      account&.orgainization_name
    end

    def full_name
      "#{first_name} #{last_name}"
    end

      #for store admin or reseller owner_id will be always 1
      #For normal user ower_id will be the is of Store Admin/Reseller
    def owner_id
      self.store_admin? ? 1  : (account.store_admin.try(:solid_cp_id) || 1)
    end

    def reseller_id
      self.store_admin? ? 0 : (account&.store_admin.try(:isp_config_id) || 0)
    end

    def send_devise_notification(notification, *args)
        UserMailer.send(notification, self, *args).deliver_now
    end

    def ensure_valid_store_params
      return unless self.reseller_signup?
      store = StoreManager::StoreCreator.new(self).store
      return if store.valid?
    
      self.errors.merge!(store.errors)
    end

    def update_user_tanent
      tenant_id = 
      if TenantManager::TenantHelper.current_admin_tenant? || TenantManager::TenantHelper.current_tenant.blank?
        TenantManager::TenantHelper.admin_tenant_id
      else
        TenantManager::TenantHelper.current_tenant_id
      end
      
      ActsAsTenant.without_tenant { self.update_column :account_id, tenant_id}
    end

    def active_for_authentication?
      if self.superadmin?
        super && true
      elsif self.store_admin?
        if TenantManager::TenantHelper.current_admin_tenant?
          super
        else
          super && self.account_id == TenantManager::TenantHelper.current_tenant_id
        end
      else
        super && self.account_id == TenantManager::TenantHelper.current_tenant_id
      end
    end

    def marketplace_url
      if self.store_admin?
        get_subdomain_from_redis
      else
        self.account.spree_store.url
      end
    end

    def save_subdomain_to_redis
      return unless self.reseller_signup?
      url = "#{self.subdomain}.#{ENV['BASE_DOMAIN']}"

      AppManager::RedisWrapper.set(reseller_subdomain_redis_key,url)
    end

    def get_subdomain_from_redis
      return unless self.reseller_signup?

      AppManager::RedisWrapper.get(reseller_subdomain_redis_key) || self.account.spree_store.url
    end

    def reseller_subdomain_redis_key
      "reseller_id_#{self.id}_domain"
    end

    def inactive_message
      return super unless self.confirmed?

      "Invalid Username or Password"
    end
  
  end
end

::Spree::User.prepend Spree::UserDecorator if ::Spree::User.included_modules.exclude?(Spree::UserDecorator)
Spree::PermittedAttributes.user_attributes.push << :first_name
Spree::PermittedAttributes.user_attributes.push << :last_name
Spree::PermittedAttributes.user_attributes.push << :subdomain
Spree::PermittedAttributes.user_attributes.push << :reseller_signup
Spree::PermittedAttributes.user_attributes.push << :business_name






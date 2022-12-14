# frozen_string_literal: true

module Spree
  module ProductDecorator

    MONTHLY_VALIDITY     = "plan-validity-monthly"
    SEMI_ANNUAL_VALIDITY = "plan-validity-semi-annual"
    ANNUAL_VALIDITY      = "plan-validity-annual"

    def self.prepended(base)
      base.validate :ensure_server_type_do_not_change, on: [:update]
      base.after_initialize :set_available_date, :set_validity
      base.acts_as_tenant :account, class_name: '::Account'
      base.has_many :plan_quota_groups, class_name: 'PlanQuotaGroup', dependent: :destroy, extend: FirstOrBuild
      base.has_many :plan_quotas, through: :plan_quota_groups, dependent: :destroy
      base.has_one :isp_config_limit, inverse_of: :product, autosave: true, dependent: :destroy
      base.after_commit :ensure_plan_id_or_template_id, on: [:create]
      base.after_commit :add_to_tenant, on: %i[create update]
      base.after_commit :update_solid_cp_plan, on: [:update]
      base.after_commit :update_stock_availibility, on: [:create]
      base.accepts_nested_attributes_for :plan_quota_groups, reject_if: :reject_if_not_windows, allow_destroy: true
      base.accepts_nested_attributes_for :isp_config_limit, reject_if: :reject_if_not_linux

      base.scope :reseller_products, -> { where(reseller_product: true) }


      base.validates :server_type, presence: { message: "can't be blank"}

      base.enum server_type: {
        windows: 0,
        linux: 1,
        domain: 2,
        hsphere: 3,
        reseller_plan: 4
      }
      base.has_one :product_config
      # base.after_create :create_product_config
      base.whitelisted_ransackable_attributes = %w[description name slug discontinue_on account_id]
    end

    def set_validity
      self.validity = 1
    end

    # def create_product_config
    #   AppManager::ProductConfigCreator.new(self,isp_config_limit.as_json,plan_quotas.as_json).call
    # end
    
    def ensure_plan_id_or_template_id
      if windows?  #TODO we may remove windows and linux option as seprate plan later
        update(isp_config_master_template_id: nil)
        return nil if solid_cp_master_plan_id.present? && TenantManager::TenantHelper.current_tenant.blank?

        update(solid_cp_master_plan_id: account.spree_store.solid_cp_master_plan_id)

        HostingPlanJob.perform_later(id)

      elsif linux?
        update(solid_cp_master_plan_id: nil)
        return nil if isp_config_master_template_id.present?

        update(isp_config_master_template_id: account.spree_store.isp_config_master_template_id)
      elsif reseller_plan?
        update(solid_cp_master_plan_id: solid_cp_master_plan_id)
        update(solid_cp_plan_id: solid_cp_master_plan_id)
      end
    end

    def add_to_tenant
      if account_id.blank?
        TenantManager::ProductTenantUpdater.new(self, TenantManager::TenantHelper.admin_tenant_id).call
      end
    end

    def update_solid_cp_plan
      return if TenantManager::TenantHelper.current_tenant.blank?
      return unless windows?

      HostingPlanJob.perform_later(id, 'update')
    end

    def reject_if_not_windows(_attrs)
      !windows?
    end

    def reject_if_not_linux(_attrs)
      !(linux? || reseller_plan?)
    end

    def ensure_server_type_do_not_change
      return unless server_type_changed?

      errors.add(:plan_type, 'cannot be changed.')
    end

    def set_available_date
      return if persisted?

      self.available_on = Time.zone.now
    end

    def update_stock_availibility
      stock_items.each do |stock_item|
        stock_item.stock_movements.create({ quantity: 1000 })
      end
    end
  end
end

::Spree::Product.prepend Spree::ProductDecorator if ::Spree::Product.included_modules.exclude?(Spree::ProductDecorator)

[:plan_type, :server_type, :solid_cp_master_plan_id, :isp_config_master_template_id, :subscribable, :reseller_product, :no_of_website, :storage, :ssl_support, :domain, :subdomain, :parked_domain, :mailbox, :auto_daily_malware_scan, :email_order_confirmation, :frequency, :visible,
 { isp_config_limit_attributes: IspConfigLimit.get_fields_name,
   plan_quota_groups_atrributes: [:group_name, :product_id, :solid_cp_quota_group_id, :calculate_diskspace, :calculate_bandwidth, :enabled, :id,
                                  { plan_quotas_attributes: %i[quota_name plan_quota_group_id solid_cp_quota_group_id solid_cp_quota_id quota_value unlimited enabled parent_quota_value id quota_type_id] }] }].each do |field|
  Spree::PermittedAttributes.product_attributes.push << field
end

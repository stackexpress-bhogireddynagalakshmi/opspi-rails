# frozen_string_literal: true

module AppManager
  class AccountProvisioner
    attr_reader :user, :product, :order

    def initialize(user, options = {})
      @user = user
      @product = options[:product]
      @order = options[:order]
    end

    def call
      return if @order.blank?
      Rails.logger.info { "AccountProvisioner is called " }
      
      provison_accounts if @order.panels_access('solid_cp')
      
      provision_isp_config_account if @order.panels_access('isp_config')

      provison_accounts if @order.panels_access('reseller_plan')
      
    end

    def provison_accounts
        SolidCpProvisioningJob.set(wait: 3.second).perform_later(user.id, product&.id)

        IspConfigProvisioningJob.set(wait: 3.second).perform_later(user.id, product&.id)
        Rails.logger.info { "SolidCpProvisioningJob is scheduled to create user account on solid CP " }
    end

    def provision_isp_config_account 
      IspConfigProvisioningJob.set(wait: 3.second).perform_later(user.id, product&.id)
      Rails.logger.info { "IspConfigProvisioningJob is scheduled to create user account on ISPConfig Account " }
    end
  end
end

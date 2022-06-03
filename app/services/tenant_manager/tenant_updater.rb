module TenantManager
  class TenantUpdater
    attr_reader :account,:order

      # This service class is responsible for giving the access for SolidCP and ISP config
      # It expect the tenant(account) and order object
      # it iterate on orders line item and check for the type of product purchased and assign the access
      # this service only get executed on the admin tenant eg admin.dev
 
      def initialize(account,options = {})
        @account = account
        @order = options[:order]
      end

      def call
        Rails.logger.info { "TenantUpdater is called. " }
        return if account.blank?
        return if order.blank?
        return unless TenantManager::TenantHelper.current_admin_tenant? # return if current store is not super admin store

        
        if @order.panels_access('solid_cp') || @order.panels_access('reseller_plan')
          setup_solid_cp_access
        end

        if @order.panels_access('isp_config')
          setup_isp_config_access
        end

      end


       #Solid CP Access to tenant  & Master Plan id set for a spree store
      def setup_solid_cp_access
      
        Rails.logger.info { 
          "setup_panels_access method is called. SolidCP Access: #{@order.panels_access('solid_cp')} " 
        }
      
        account.update_column :solid_cp_access, true 
        account.spree_store.update_column :solid_cp_access, true

        solid_cp_plan_id = order.subscribable_products.pluck(:solid_cp_master_plan_id).last

        account.spree_store.update(solid_cp_master_plan_id: solid_cp_plan_id)
      end

      #ISP config Access to tenant & Master Plan id set for a spree store
      def setup_isp_config_access

        Rails.logger.info { "setup_panels_access method is called. ISPConfig Access: #{panels_access('isp_config')} " }

        account.update_column :isp_config_access, true 
          account.spree_store.update_column :isp_config_access, true 
        
        account.spree_store.update(isp_config_master_template_id: order.subscribable_products.linux.first.isp_config_master_template_id) rescue nil
      end
  end
end
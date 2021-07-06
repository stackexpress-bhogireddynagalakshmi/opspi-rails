module TenantManager
  class TenantUpdater
    attr_reader :account,:order, :product

     #for reseller only
      def initialize(account,options = {})
        @account = account
        @product = options[:product]
        @order = options[:order]
      end

      def call
        
      end

      def setup_panels_access
        return if account.blank?
        return if product.blank?
        return unless TenantManager::TenantHelper.current_admin_tenant?

        #Solid CP Access to tenant  & Master Plan id set for a spree store

        account.update_column :solid_cp_access, true if panels_access('solid_cp')
        account.spree_store.update_column :solid_cp_access,true  if panels_access('solid_cp')
        account.spree_store.update(solid_cp_master_plan_id: order.subscribable_products.windows.first.solid_cp_master_plan_id) if  order.subscribable_products.windows.present?

         #ISP config Access to tenant & Master Plan id set for a spree store
        account.update_column :isp_config_access, true if panels_access('isp_config')
        account.spree_store.update_column :isp_config_access, true if panels_access('isp_config')
        account.spree_store.update(isp_config_master_template_id: order.subscribable_products.linux.first.isp_config_master_template_id) if  order.subscribable_products.linux.present?
      
      end

      private

      def panels_access(panel)
        @panels = []
          if order.present?        
              order.line_items.each do |line_item|
                panel_name = line_item.product.windows? ? 'solid_cp' : 'isp_config' 
                @panels << panel_name  if !@panels.include?(panel)
            end
          end
          @panels.include?(panel)
      end
  end
end
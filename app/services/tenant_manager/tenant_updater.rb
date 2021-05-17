module TenantManager
	class TenantUpdater
		attr_reader :account,:order, :product

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

  			byebug
			account.update(solid_cp_access: true) if panels_access('solid_cp')
			account.update(isp_config_access: true) if panels_access('windows')
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
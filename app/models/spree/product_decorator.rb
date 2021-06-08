
module Spree
	module ProductDecorator

		def self.prepended(base)
	    	base.acts_as_tenant :account,:class_name=>'::Account'
	    	base.has_many :susbscriptions,:class_name=>'Subscription'
	    	base.has_many :plan_quota_groups,:class_name=>'PlanQuotaGroup',dependent: :destroy,:extend => FirstOrBuild
	    	base.has_many :plan_quotas,:through=>:plan_quota_groups,dependent: :destroy
	    	base.after_commit :ensure_plan_id_or_template_id, on: [:create]
	    	base.after_commit :add_to_tenant, on: [:create]

	    	base.accepts_nested_attributes_for :plan_quota_groups,:reject_if => lambda {|a|a[:enabled] == false},allow_destroy: true
	    	base.scope :reseller_products, ->{where(reseller_product: true)}

	    	base.enum server_type: {
				windows: 0,
				linux: 1
			}
	  	end


	  	def ensure_plan_id_or_template_id

	  		if self.windows?
	  			self.update(isp_config_master_template_id: nil) 
	  		
	  			return if self.solid_cp_master_plan_id.present?  && TenantManager::TenantHelper.current_admin_tenant?
	  		
	  			self.update(solid_cp_master_plan_id: account.spree_store.solid_cp_master_plan_id) 

	  			HostingPlanJob.perform_later(self.id)

	  		elsif self.linux?
	  			self.update(solid_cp_master_plan_id: nil)

	  			return if self.isp_config_master_template_id.present?
	  			self.update(isp_config_master_template_id: account.spree_store.isp_config_master_template_id) 
	  		end
	  	end

	  	def add_to_tenant
	  		if self.account_id.blank?
	  			TenantManager::ProductTenantUpdater.new(self,1).call
	  		end

	  	end

	  	# def ensure_no_active_subscription
	    #    if susbscriptions.active.present?
	    #      errors.add(:base, "You can not delete a plan with active subscriptions")
	    #      throw :abort
	    #    end
	    #  end

	end
end

::Spree::Product.prepend Spree::ProductDecorator if ::Spree::Product.included_modules.exclude?(Spree::ProductDecorator)

[:plan_type,:server_type,:solid_cp_master_plan_id,:isp_config_master_template_id,:subscribable,:reseller_product,:no_of_website,:storage,:ssl_support,:domain,:subdomain,:parked_domain,:mailbox,:auto_daily_malware_scan,:email_order_confirmation,
	:plan_quota_groups_atrributes=>
	[:group_name,:product_id,:solid_cp_quota_group_id,:calculate_diskspace,:calculate_bandwidth,:enabled,:id,
		:plan_quotas_attributes=>
		[:quota_name,:plan_quota_group_id,:solid_cp_quota_group_id,:solid_cp_quota_id,:quota_value,:unlimited,:enabled,:parent_quota_value,:id]]
	].each do |field|
	
	Spree::PermittedAttributes.product_attributes.push << field
end



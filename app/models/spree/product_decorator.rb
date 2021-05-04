
module Spree
	module ProductDecorator

		PLAN_TYPE ||= [['Shared Hosting','SHARED_HOSTING'],['VPS Hosting','VPS_HOSTING'],['Dedicated Hosting','DEDICATED_HOSTING']].freeze

		def self.prepended(base)
	    	base.acts_as_tenant :account,:class_name=>'::Account'
	    	base.has_many :susbscriptions,:class_name=>'Subscription'
	    	base.has_many :plan_quota_groups,:class_name=>'PlanQuotaGroup',dependent: :destroy,:extend => FirstOrBuild
	    	base.has_many :plan_quotas,:through=>:plan_quota_groups,dependent: :destroy
	    	base.after_commit :add_to_solid_cp, on: [:create]
	    	base.accepts_nested_attributes_for :plan_quota_groups,:reject_if => lambda {|a|a[:enabled] == false},allow_destroy: true
	    	#base.accepts_nested_attributes_for :plan_quotas,:reject_if => lambda {|a|a[:quota_value].blank?},allow_destroy: true

	    	#base.before_update :ensure_no_active_subscription, if: :deleted_at_changed?
	  	end


	  	def add_to_solid_cp
	  		if self.solid_cp_master_plan_id.blank? 
		  		self.solid_cp_master_plan_id = account.spree_store.solid_cp_master_plan_id
		  		self.save
		  	end
	  		HostingPlanJob.perform_later(self.id)
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

[:plan_type,:solid_cp_master_plan_id,:subscribable,:no_of_website,:storage,:ssl_support,:domain,:subdomain,:parked_domain,:mailbox,:auto_daily_malware_scan,:email_order_confirmation,
	:plan_quota_groups_atrributes=>
	[:group_name,:product_id,:solid_cp_quota_group_id,:calculate_diskspace,:calculate_bandwidth,:enabled,:id,
		:plan_quotas_attributes=>
		[:quota_name,:plan_quota_group_id,:solid_cp_quota_group_id,:solid_cp_quota_id,:quota_value,:unlimited,:enabled,:parent_quota_value,:id]]
	].each do |field|
	
	Spree::PermittedAttributes.product_attributes.push << field
end



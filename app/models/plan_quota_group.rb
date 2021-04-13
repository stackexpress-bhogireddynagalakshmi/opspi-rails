class PlanQuotaGroup < ApplicationRecord
	has_many :plan_quotas,:class_name=>'PlanQuota',:foreign_key=>'plan_quota_group_id',:extend => FirstOrBuild
	# belongs_to :product,:class_name=>'Spree::product',:foreign_key=>'product_id'
	accepts_nested_attributes_for :plan_quotas,:reject_if => :check_validation?,allow_destroy: true



	def check_validation?(attributes)
		!self.enabled
	end

end

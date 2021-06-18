class PlanQuota < ApplicationRecord
	self.table_name = "plan_quotas"
	# belongs_to :plan_quota_group


	def formatted_quota_name
		arr = quota_name.split(".")
		if arr.size > 1
			 name_str = arr[1].snakecase.titleize
			 name_str = name_str.gsub('Ssl','SSL')
			 name_str = name_str.gsub('Ip', 'IP')
			 name_str = name_str.gsub('Cgi','CGI')
			 name_str
		else
			arr[0]
		end
	end
end

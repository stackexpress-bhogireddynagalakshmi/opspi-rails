module HostingHelper
	
	def quota_list(product)
		quotas = quota_list_objects(product)
		list_arr = []
		quotas.each do |quota|
			if quota.quota_name == 'OS.Diskspace'
				list_arr << formatted_quota_text(quota,"GB") if !list_arr.join(" ").include?("Diskspace") 
			else
				list_arr << formatted_quota_text(quota)	if !list_arr.join(" ").include?(quota.formatted_quota_name)
			end
		end
		list_arr.compact.uniq
	end


	def formatted_quota_text(quota, unit="")
		if quota.quota_value == -1
			"Unlimitted #{quota.formatted_quota_name}"
		elsif quota.quota_value == 0
			nil			
		else
			"#{quota.quota_value} #{unit} #{quota.formatted_quota_name}"
		end
	end

	def quota_list_objects(product)
		product.plan_quotas.select{|k| ["Web.Sites",'OS.Diskspace',"OS.Domains","OS.SubDomains","Web.SharedSSL","Mail.Accounts","FTP.Accounts"].include?(k.quota_name)}
	end
	
end

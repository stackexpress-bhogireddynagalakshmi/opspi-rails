module AccountHelper

	def render_hosting_plan_quota_partial(product,user,solid_cp_plan_id)
	  if user.store_admin?
	 	 solid_cp_plan_id = current_store.solid_cp_master_plan_id
	  end
    if solid_cp_plan_id.present?
      response = SolidCp::Plan.get_hosting_plan_quotas(solid_cp_plan_id)
      groups  = response.body[:get_hosting_plan_quotas_response][:get_hosting_plan_quotas_result][:diffgram][:new_data_set][:table]  
      groups = groups.select{|x| x[:enabled]}
      quotas  = response.body[:get_hosting_plan_quotas_response][:get_hosting_plan_quotas_result][:diffgram][:new_data_set][:table1]     
      build_plan_quotas(product,groups,quotas)

      render :partial=> 'spree/admin/products/solid_cp_quota_groups',:locals=>{quota_groups: groups,quotas: quotas,:layout=>false}
    else
      ""
    end
	end

  def build_plan_quotas(product,groups,quotas)
    groups.each do |group|
     	group_obj = product.plan_quota_groups.first_or_build({:solid_cp_quota_group_id=>group[:group_id]})
     	group_obj.group_name = group[:group_name]
     	group_obj.enabled = group[:enabled]
	 end
  end

  def build_quota(product,group_obj,quotas)
    quotas.select{|x|x[:group_id].to_i == group_obj.solid_cp_quota_group_id}.each do |quota|
		    quota_obj = group_obj.plan_quotas.first_or_build({:solid_cp_quota_id=>quota[:quota_id]})
		    if quota_obj.id.blank?
		     	quota_obj.assign_attributes({:quota_name=>quota[:quota_name],:quota_value=>quota[:quota_value],:solid_cp_quota_group_id=>quota[:group_id]})
		    end
		end
		group_obj.plan_quotas
  end

end

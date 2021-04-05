module SolidCp

	class Plan < Base

		attr_reader :user,:plan

		client wsdl: SOAP_PLAN_WSDL, endpoint: SOAP_PLAN_WSDL,log: SolidCp::Config.log
		global :open_timeout, SolidCp::Config.timeout
  		global :basic_auth, SolidCp::Config.username, SolidCp::Config.password

  		operations :get_hosting_plans, :get_hosting_addons, :get_hosting_plan, :get_hosting_plan_quotas, 
  			:get_hosting_plan_context, :get_user_available_hosting_plans, :get_user_available_hosting_addons, 
  			:add_hosting_plan, :update_hosting_plan, :delete_hosting_plan, :search_service_items_paged, 
  			:get_search_object,:get_search_object_quick_find,:get_search_table_by_columns, 
  			:get_searchable_service_item_types, :send_account_summary_letter, :get_evaluated_account_template_body, 
  			:get_overusage_summary_report, :get_diskspace_overusage_details_report, :get_bandwidth_overusage_details_report


  		
	    def initialize user,plan
	       @user = user
	       @plan = plan
	    end


	    def add_hosting_plan
	    	# ServerId

	    	if plan.solid_cp_plan_id.blank?
	    		
	    		user.solid_cp.package.add_package if user.packages.blank?
	    		
				response = super(message: { 
			   		plan: {
			   			"PackageId" => user.packages.first.try(:solid_cp_package_id),
				   		"PlanName" => plan.name,
				   		"PlanDescription"=>plan.description,
				   		"Available"=> true,
				   		"IsAddon"=> false,
				   		"SetupPrice"=> 0.0,
				   		"RecurringPrice" =>0.0000,
				   		"RecurrenceUnit"=> 2,
				   		"RecurrenceLength" =>1,
				   		"UserId"=>user.solid_cp_id	   		
			   		}
			   	 })
				# "Groups" => {

				#    		},

				if response.success? && response.body[:add_hosting_plan_response][:add_hosting_plan_result].to_i > 0 
					plan.solid_cp_plan_id = response.body[:add_hosting_plan_response][:add_hosting_plan_result].to_i
					plan.save!
				else
					{:success=>false,:message=> "Something went wrong. Please try again.",response: response}
				end
			else
					{:success=>true,:message=> "Plan Already exists.",response: response}
			end

	    end

	end
end

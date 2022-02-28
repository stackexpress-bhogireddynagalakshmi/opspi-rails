# frozen_string_literal: true

module SolidCp
  class Plan < Base
    attr_reader :user, :plan

    client wsdl: SOAP_PLAN_WSDL, endpoint: SOAP_PLAN_WSDL, log: SolidCp::Config.log
    global :read_timeout, SolidCp::Config.timeout
    global :open_timeout, SolidCp::Config.timeout
    global :basic_auth, SolidCp::Config.username, SolidCp::Config.password

    operations :get_hosting_plans, :get_hosting_addons, :get_hosting_plan, :get_hosting_plan_quotas,
               :get_hosting_plan_context, :get_user_available_hosting_plans, :get_user_available_hosting_addons,
               :add_hosting_plan, :update_hosting_plan, :delete_hosting_plan, :search_service_items_paged,
               :get_search_object, :get_search_object_quick_find, :get_search_table_by_columns,
               :get_searchable_service_item_types, :send_account_summary_letter, :get_evaluated_account_template_body,
               :get_overusage_summary_report, :get_diskspace_overusage_details_report, :get_bandwidth_overusage_details_report

    def initialize(user, plan)
      @user = user
      @plan = plan
    end

    def self.get_hosting_plans
      response = super(message: { user_id: 1 })
    end

    def get_hosting_plans
      response = super(message: { user_id: user.solid_cp_id })
    end

    def add_hosting_plan
      # ServerId will be used to create master plan
      if plan.solid_cp_plan_id.blank?

        user.solid_cp.package.add_package(plan.solid_cp_master_plan_id)

        response = super(message: {
          plan: {
            "PackageId" => user.packages.first.try(:solid_cp_package_id),
            "PlanName" => plan.name,
            "PlanDescription" => plan.description,
            "Available" => true,
            "IsAddon" => false,
            "SetupPrice" => 0.0,
            "RecurringPrice" => 0.0000,
            "RecurrenceUnit" => 2,
            "RecurrenceLength" => 1,
            "Groups" => get_hosting_plan_groups_info,
            "Quotas" => get_hosting_plan_quotas_info,
            "UserId" => user.solid_cp_id
          }
        })

        if response.success? && response.body[:add_hosting_plan_response][:add_hosting_plan_result].to_i.positive?
          plan.solid_cp_plan_id = response.body[:add_hosting_plan_response][:add_hosting_plan_result].to_i
          plan.save!
        else
          { success: false, message: "Something went wrong. Please try again.", response: response }
        end
      else
        { success: true, message: "Plan Already exists.", response: response }
      end
    end

    def update_hosting_plan
      if plan.solid_cp_plan_id.present?

        response = super(message: {
          plan: {
            "PlanId" => plan.solid_cp_plan_id,
            "PackageId" => user.packages.first.try(:solid_cp_package_id),
            "PlanName" => plan.name,
            "PlanDescription" => plan.description,
            "Available" => true,
            "IsAddon" => false,
            "SetupPrice" => 0.0,
            "RecurringPrice" => 0.0000,
            "RecurrenceUnit" => 2,
            "RecurrenceLength" => 1,
            "Groups" => get_hosting_plan_groups_info,
            "Quotas" => get_hosting_plan_quotas_info,
            "UserId" => user.solid_cp_id
          }
        })
      end
    end

    def get_hosting_plan_groups_info
      group_hash = {}
      arr = plan.plan_quota_groups.collect do |quota_group|
        {
          "GroupId" => quota_group.solid_cp_quota_group_id,
          "Enabled" => quota_group.enabled,
          "CalculateDiskSpace" => quota_group.calculate_diskspace,
          "CalculateBandwidth" => quota_group.calculate_bandwidth
        }
      end
      group_hash["HostingPlanGroupInfo"] = arr
      group_hash
    end

    def get_hosting_plan_quotas_info
      quota_hash = {}
      arr = plan.plan_quotas.uniq(&:solid_cp_quota_id).collect do |plan_quota|
        {
          "QuotaId" => plan_quota.solid_cp_quota_id,
          "QuotaValue" => plan_quota.quota_value
        }
      end
      quota_hash["HostingPlanQuotaInfo"] = arr
      quota_hash
    end

    def self.get_hosting_plan_quotas(plan_id)
      response = begin
        super(message: { plan_id: plan_id })
      rescue StandardError
        []
      end
    end

    # syncronous api call
    def get_hosting_plan_quotas
      response = super(message: { plan_id: plan.solid_cp_plan_id })
    end

    # syncronous api call
    def self.master_plans_dropdown
      response = SolidCp::Plan.get_hosting_plans
      plans = response.body[:get_hosting_plans_response][:get_hosting_plans_result][:diffgram][:new_data_set][:table]

      plans.collect { |x| [x[:plan_name], x[:plan_id]] }
    rescue Exception => e
      Rails.logger.error { e.message }
      plans = []
    end
  end
end

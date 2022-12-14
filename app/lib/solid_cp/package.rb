# frozen_string_literal: true

module SolidCp
  class Package < Base
    attr_reader :user

    def initialize(user)
      @user = user

      set_configurations(user, SOAP_PLAN_WSDL)
    end

    operations :get_packages, :get_nested_packages_summary, :get_raw_packages, :get_packages_paged, :get_my_packages,
               :get_raw_my_packages, :get_package, :get_package_context, :get_package_quotas, :get_package_quotas_for_edit,
               :add_package, :update_package, :update_package_literal, :update_package_name,
               :delete_package, :change_package_status, :evaluate_user_package_tempate, :get_package_settings, :update_package_settings,
               :set_default_top_package, :get_package_addons, :get_package_addon, :add_package_addon_by_id, :add_package_addon,
               :add_package_addon_literal, :update_package_addon, :update_package_addon_literal, :delete_package_addon,
               :get_raw_package_items_by_type, :get_raw_package_items_paged, :get_raw_package_items,
               :detach_package_item, :move_package_item, :get_package_quota, :send_package_summary_letter, :get_evaluated_package_template_body,
               :add_package_with_resources, :create_user_wizard, :get_package_packages, :get_nested_packages_paged,
               :get_packages_bandwidth_paged, :get_packages_diskspace_paged, :get_package_bandwidth, :get_package_diskspace


   
    # Creates Hosting Space on SolidCP for a user

    def  add_package(plan_id = 10)
      if user.packages.where(solid_cp_master_plan_id: plan_id).first.blank?
        org_name = TenantManager::TenantHelper.unscoped_query { user.account.orgainization_name }
        response = super(message: {
          user_id: user.solid_cp_id,
          plan_id: plan_id,
          package_name: "#{org_name.snakecase}_hosting_space_#{plan_id}",
          package_comments: "Hosting space for #{user.full_name}",
          status_id: 1,
          purchase_date: Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
        })

        if response.success? && response.body[:add_package_response][:add_package_result][:result].to_i.positive?
          user.packages.create({ solid_cp_package_id: response.body[:add_package_response][:add_package_result][:result],
                                 solid_cp_master_plan_id: plan_id })
          { success: true, message: 'SolidCP Package created successfully', response: response }
        else
          { success: true, message:  SolidCp::ErrorHelper.log_solid_cp_error(response, __method__), response: response }
        end
      else
        { success: true, message: 'SolidCP Package already exists' }
      end
    end

    def get_package_context
      response = super(message: {
        package_id: user.packages.first.try(:solid_cp_package_id)
      })
    end

    def get_package_diskspace
      response = super(message: {
        package_id: user.packages.first.try(:solid_cp_package_id)
      })
    end

    def get_package_bandwidth
      response = super(message: {
        package_id: user.packages.first.try(:solid_cp_package_id),
        start_date: today.to_date.beginning_of_month,
        end_date: today.to_date.end_of_month
      })
    end
    
    def today
      DateTime.now
    end
  end
end

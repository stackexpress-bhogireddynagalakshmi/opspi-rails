class SolidCpProvisioningJob < ApplicationJob
  queue_as :default

  #constant defined for SolidCP Resources
  ADMIN_ROLE_ID = 1
  RESELLER_ROLE_ID = 2 
  USER_ROLE_ID = 3
  RESELLER_PLAN_ID = 10


  # Create user on SolidCP and Provision accounts
  # This job will create User Account on SolidCP and Provision the hosting Space for Reseller & User
  # static Plan Id 10 used for Reseller As of Now
  # FOr End User Real Plan ID will be Provided

  def perform(user_id,product_id=nil)
    user = Spree::User.find(user_id)
    if user.store_admin? # reseller
    	provision_store_admin_account(user,product_id)
    else
    	provision_user_account(user,product_id)
    end if user.account&.solid_cp_access?
  end


  private

  def subscribe_to_solidcp_plan(user,plan_id)
  	  user.solid_cp.package.add_package(plan_id) 
  end

  # this will provision the store Admin/Reseller Account and also creates hosting space for the reseller on solidcp panel
  def provision_store_admin_account(user,product_id)
    response = user.solid_cp.add_user('Reseller',RESELLER_ROLE_ID)
    
    solid_cp_master_plan_id = user.spree_store.solid_cp_master_plan_id || RESELLER_ROLE_ID
    if response[:success] == true
     subscribe_to_solidcp_plan(user,solid_cp_master_plan_id) if user.packages.count <= 1
    else
      raise StandardError.new response[:message] 
    end
  end

  # this will provision the store User Account and also creates hosting_space/Subscribe the plan on solidcp panel if product_id is passed is given
  def provision_user_account(user,product_id)
   response = user.solid_cp.add_user
     if response[:success] == true
       # this will only subscribe to plan if product id is given
        if product_id.present?
          product = Spree::Product.find(product_id)
          if  product.solid_cp_plan_id.present?  
            subscribe_to_solidcp_plan(user,product.solid_cp_plan_id)
          else
            HostingPlanJob.perform(product_id)
            raise StandardError.new "SolidCP Plan for this Product:##{product.id}-#{product.name} does not exist. HostingPlanJob started."
          end 
        end
     else
         raise StandardError.new response[:message] 
     end
  end


  # def solid_cp_response
  #     yield if block_given?
  # end
end

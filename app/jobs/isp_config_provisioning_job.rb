class IspConfigProvisioningJob < ApplicationJob
  queue_as :default

  def perform(user_id,product_id=nil)
    user = Spree::User.find(user_id)  
    if user.store_admin? # reseller
    	provision_store_admin_account(user,product_id)
    else
    	provision_user_account(user,product_id)
    end     
  end

  private

  def provision_store_admin_account(user,product_id)
  	response  = user.isp_config.create(product_id)
    if response[:success] == true   
      isp_config_master_template_id = user.spree_store.isp_config_master_template_id || 1
      #attach_to_isp_config_tenplate(user,isp_config_master_template_id) #if user.packages.count <= 1
    else
      raise StandardError.new response[:message]
    end
  end

  def provision_user_account(user,product_id)
   	response = user.isp_config.create(product_id)
    if response[:success] == true   
      if product_id.present?
        product = Spree::Product.find(product_id)
        if product.isp_config_master_template_id.present?
            #attach_to_isp_config_tenplate(user,product.isp_config_master_template_id)
        else
          #raise StandardError.new "ISP  Config Template for this Product:##{product.id}-#{product.name} does not exist. HostingPlanJob started."
        end
      end
    else
      raise StandardError.new response[:message]  
    end
  end

  def attach_to_isp_config_tenplate(user,template_id)
    user.isp_config.attach_template(template_id) 
  end

end

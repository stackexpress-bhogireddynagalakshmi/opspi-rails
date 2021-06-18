class HostingPlanJob < ApplicationJob
  queue_as :default

  #this Job will create Hosting Plans on SolidCP Server

  def perform(product_id,action='create')
    product = Spree::Product.find(product_id)
    reseller = product.account&.store_admin
    return unless reseller.present?

    if action == 'create'
    	reseller.solid_cp.plan(product).add_hosting_plan
    else
    	reseller.solid_cp.plan(product).update_hosting_plan
    end
  end
  
end

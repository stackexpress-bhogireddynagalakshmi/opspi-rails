class HostingPlanJob < ApplicationJob
  queue_as :default

  #this Job will create Hostingf Plans on SolidCP Server

  def perform(product_id)
    product = Spree::Product.find(product_id)
    reseller = product.account&.store_admin
    reseller.solid_cp.plan(product).add_hosting_plan if reseller.present?
  end
  
end

module ImportManager
    class PlanImporter < BaseImporter
      
      require 'csv'    
  
      def initialize(file,options={})
        @file = file
      end
  
      def call
       
          @start = Time.now
          Rails.logger.debug {"Plan import Started at #{@start}"}
  
          count = 0
          
          @file.each_slice(1000).with_index do |plans, index|

              plans.each do |plan|
                next if plan[0] == 'plan_name' || plan[0].downcase == 'plan name'
                
                Rails.logger.info { "Start Importing Product #{plan[0]}"}
                
                ActsAsTenant.with_tenant(current_tenant(plan)) do
                 
                  Spree::Product.transaction do
  
                    product_obj = Spree::Product.new({
                      name: plan[0],
                      account_id: plan[5], #opspi account id
                      subscribable: plan[3],
                      server_type: "hsphere",
                      validity: plan[2],
                      price: plan[1],
                      shipping_category_id: 1,
                      visible: plan[4]
                    })
  
                    product_obj.save!
                    
                    count+=1
  
                    Rails.logger.info { "Start Importing Product #{plan[0]}"}
                  end
                end
              end
            end
        return {total_time: (Time.now - @start),count: count}
      end
  
      private
  
      def current_tenant(plan)
        Account.find(plan[5])
      end
  
    end
  end
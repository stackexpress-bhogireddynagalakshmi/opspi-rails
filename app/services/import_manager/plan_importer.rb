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
                      account_id: plan[7], #opspi account id
                      subscribable: plan[5],
                      server_type: "hsphere",
                      validity: plan[4],
                      price: plan[1],
                      shipping_category_id: 1,
                      visible: plan[6]
                    })
  
                    product_obj.save!
                    
                    product_id = product_obj.id
                    option_type_id = Spree::OptionType.where(name: "plan-validity").first.id
                    
                    product_option_type_obj = Spree::ProductOptionType.new({
                      position: 1,
                      product_id: product_id,
                      option_type_id: option_type_id
                    })
                    
                    product_option_type_obj.save!

                    option_value_monthly = Spree::OptionValue.where(option_type_id: option_type_id, name: "plan-validity-monthly").first
                    option_value_semi_annual = Spree::OptionValue.where(option_type_id: option_type_id, name: "plan-validity-semi-annual").first
                    option_value_annual = Spree::OptionValue.where(option_type_id: option_type_id, name: "plan-validity-annual").first

          
                      Spree::Variant.transaction do
  
                        variant_obj = Spree::Variant.new({
                          product_id: product_id,
                          cost_currency: "USD", 
                          position: 2,
                          is_master: 0,
                          option_values: [option_value_monthly],
                          price: plan[1]
                        })

                        variant_obj.save!

                        variant2_obj = Spree::Variant.new({
                          product_id: product_id,
                          cost_currency: "USD", 
                          position: 3,
                          is_master: 0,
                          option_values: [option_value_semi_annual],
                          price: plan[2]
                        })

                        variant2_obj.save!

                        variant3_obj = Spree::Variant.new({
                          product_id: product_id,
                          cost_currency: "USD", 
                          position: 4,
                          is_master: 0,
                          option_values: [option_value_annual],
                          price: plan[3]
                        })

                        variant3_obj.save!
                      end
                      
                    
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
        Account.find(plan[7])
      end
  
    end
  end
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
          csv_file_path = "#{Rails.root}/deployments/mapped_plans.csv"
          new_file_path = "#{Rails.root}/deployments/mapped_plans_updated.csv"
          final_file_path = "#{Rails.root}/deployments/mapped_plans_finals.csv"

          headers = ["opspi_plan", "hsphere_plan"]
          CSV.open(csv_file_path, "a+") do |csv|
            csv << headers
          end
          
          @file.each_slice(1000).with_index do |plans, index|

              plans.each do |plan|
                next if plan[0] == 'plan_name' || plan[0].downcase == 'plan name'
                
                Rails.logger.info { "Start Importing Product #{plan[0]}"}
                
                ActsAsTenant.with_tenant(current_tenant(plan)) do
                 
                  Spree::Product.transaction do
  
                    product_obj = Spree::Product.new({
                      name: plan[0],
                      account_id: plan[7], #opspi account id
                      subscribable: plan[4],
                      server_type: "hsphere",
                      price: plan[1],
                      shipping_category_id: 1,
                      visible: plan[5]
                    })
  
                    product_obj.save!
                    
                    product_id = product_obj.id
                    og_csv_file = CSV.read(csv_file_path)

                    CSV.open(new_file_path, "a+") do |csv|
                      og_csv_file.each do |row|
                        csv << [product_id,plan[8].to_i]
                      end
                    end
                    
                    option_type_id = Spree::OptionType.where(name: "plan-validity").first.id
                    
                    product_option_type_obj = Spree::ProductOptionType.new({
                      position: 1,
                      product_id: product_id,
                      option_type_id: option_type_id
                    })
                    
                    product_option_type_obj.save!

                    option_value_monthly = Spree::OptionValue.where(option_type_id: option_type_id, name: Spree::Product::MONTHLY_VALIDITY).first
                    option_value_semi_annual = Spree::OptionValue.where(option_type_id: option_type_id, name: Spree::Product::SEMI_ANNUAL_VALIDITY).first
                    option_value_annual = Spree::OptionValue.where(option_type_id: option_type_id, name: Spree::Product::ANNUAL_VALIDITY).first

          
          
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

            CSV.open(final_file_path, 'w', write_headers: true, headers: headers) do |dest|
              CSV.open(new_file_path) do |source|
                source.each do |row|
                  dest << row
                end
              end
            end
            File.delete(new_file_path) if File.exist?(new_file_path)
            File.delete(csv_file_path) if File.exist?(csv_file_path)

        return {total_time: (Time.now - @start),count: count}
      end
  
      private
  
      def current_tenant(plan)
        Account.find(plan[7])
      end
  
    end
  end
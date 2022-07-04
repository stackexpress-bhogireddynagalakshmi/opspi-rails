module ImportManager
  class UserImporter < BaseImporter
    
    require 'csv'    

    def initialize(file,options={})
      @file = file
    end

    def call
     
        @start = Time.now
        Rails.logger.debug {"User import Started at #{@start}"}

        count = 0
        total_records = 0
        
        @file.each_slice(1000).with_index do |users, index|
            all_users = []
            users.each do |user|
              next if user[0] == 'first_name' || user[0].downcase == 'first name'
              if Spree::User.find_by_email(user[2].strip).present?
                Rails.logger.info { "#{user[2].strip} already exist" }
                next
              end

              Rails.logger.info { "Start Importing User #{user[2]}"}
              
              ActsAsTenant.with_tenant(current_tenant(user)) do
               
                Spree::User.transaction do

                  user_obj = Spree::User.new({
                    first_name: user[0],
                    #middle_name: user[1],
                    last_name: user[1].strip,
                    email: user[2].strip,
                    password: user[3].strip,
                    account_id: user[4], #opspi account id
                    hsphere_user_id: user[5],
                    hsphere_account_id: user[6], #
                    hsphere_cluster_id: user[19],
                    terms_and_conditions: true

                  })

                  user_obj.save!

                  user_obj.update_column :account_id, user[4]
                  
                  
                  country = Spree::Country.find_by_iso(user[13])

                  address = Spree::Address.new({
                    first_name: user_obj.first_name,
                    last_name: user_obj.last_name,
                    address1: user[7],
                    address2: user[8],
                    city: user[9],
                    zipcode: user[10].to_i,
                    phone: user[11].to_i,
                    state_id: Spree::State.where(abbr: user[12],country_id: country.id).first&.id,
                    country_id: country.id
                  })
                  
                  address.save(validate: false)
                  user_obj.addresses << address

                  user_obj.bill_address_id = address.id
                  user_obj.ship_address_id = address.id
                  user_obj.save!
                  user_obj.confirm
                  start_date        = user[15].to_date
                  end_date          = user[16]&.to_date
                  billing_frequency = user[18]

                 product           = Spree::Product.find(user[14])

                 variants         = product.variants.each {|v| v.option_values.select{ |x| x.option_type.name == 'plan-validity'}.first }


                 if billing_frequency == '1m'
                  variant = variants.select {|v| v.option_values.pluck(:name).include?(Spree::Product::MONTHLY_VALIDITY)}
                  freq = Spree::Product::MONTHLY_VALIDITY
                 elsif billing_frequency == '6m'
                  variant = variants.select {|v| v.option_values.pluck(:name).include?(Spree::Product::SEMI_ANNUAL_VALIDITY)}
                  freq = Spree::Product::SEMI_ANNUAL_VALIDITY
                 elsif billing_frequency == '12m'
                   variant = variants.select {|v| v.option_values.pluck(:name).include?(Spree::Product::ANNUAL_VALIDITY)}
                  freq = Spree::Product::ANNUAL_VALIDITY
                 end
                  Subscription.subscribe!({
                    product: product,
                    variant: variant.first,
                    user: user_obj,
                    start_date: start_date,
                    end_date: end_date,
                    frequency: freq,
                    status: Date.today > end_date ? 0 : 1,
                    validity: billing_frequency.to_i
                  })

                  subscription = user_obj.subscriptions.where(product_id: product.id).first

                  if user[17] == 'paid'
                    subscription.invoices.last.close!
                  end

                  count+=1

                  Rails.logger.info { "Start Importing User #{user[2]}"}
                end
              end
            end
          end
      return {total_time: (Time.now - @start),count: count}
    end

    private

    def add_item_service
      Spree::Api::Dependencies.storefront_cart_add_item_service.constantize
    end

    def current_tenant(user)
      Account.find(user[4])
    end

  end
end
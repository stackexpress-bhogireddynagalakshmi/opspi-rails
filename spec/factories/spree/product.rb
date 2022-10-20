FactoryBot.define do
  factory :product, class: 'Spree::Product' do

    # transient do
    #   stock_location_id nil
    #   variant_id false
    #   count_on_hand 100
    #   backorderable false
    # end


    name {Faker::Commerce.product_name }
    description  { Faker::Lorem.sentence(word_count: 12) }
    available_on { Date.today }
    server_type  { 'windows'}
    validity { 30 }
    price { 100 }
    shipping_category_id { Spree::ShippingCategory.find_or_create_by({:name=>'Default'}).id }
    account {::Account.last}

  end
end

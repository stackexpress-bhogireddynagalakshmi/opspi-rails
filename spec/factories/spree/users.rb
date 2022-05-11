FactoryBot.define do
  factory :spree_user, class: 'Spree::User' do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { 'password' }
    confirmed_at { Time.zone.now }
    last_sign_in_ip { '0.0.0.0' }  
    terms_and_conditions { true }

    trait :with_super_admin_role do
      after :create do |admin|
        StoreManager::StoreAdminRoleAssignor.new(admin,{role: 'admin'}).call
      end
    end

    trait :with_store_admin_role do
      after :create do |admin|
        StoreManager::StoreAdminRoleAssignor.new(admin,{role: 'store_admin'}).call
      end
    end
    
  end
end



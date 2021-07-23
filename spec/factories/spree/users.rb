FactoryBot.define do
  factory :spree_user, class: 'Spree::User' do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { 'password' }
    confirmed_at { Time.zone.now }
    last_sign_in_ip { '0.0.0.0' }    
  end
end



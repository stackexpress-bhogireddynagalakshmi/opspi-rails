FactoryBot.define do
  factory :subscription do
    plan { create(:product) }
  	user {}
  	start_date { Date.today}
  	end_date {Date.today + 1.month}
  	price { 100 }
    status {true}
    frequency { 'monthly' }
    validity {30} 
  end
end

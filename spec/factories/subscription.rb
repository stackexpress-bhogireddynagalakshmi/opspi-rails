FactoryBot.define do
  factory :subscription do
    plan { nil}
  	user {}
  	start_date { Date.today}
  	end_date {Date.today + 1.month}
  	price { nil}
  

  end
end

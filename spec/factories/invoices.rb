FactoryBot.define do
  factory :invoice do
  	name { "Invoice for #{Date.today.strftime("%b %Y")}" }
 
  	account { ::Account.last}
  	started_on { Date.today}
  	finished_on {Date.today + 1.month}
    user {}
    subscription {}

  end
end

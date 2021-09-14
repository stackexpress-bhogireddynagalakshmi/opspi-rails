namespace :invoices do
  desc "Generate invoice for each user subscriptions"
  task generate_invoices: :environment do
    Account.all.each do |account|
      next if account.admin_tenant?
      account.users.each do |user|
        next unless user.subscriptions.any?
        user.subscriptions.each do |subscription|
          InvoiceManager::InvoiceCreator.new(subscription).call
          print "."
        end
      end
    end
  end
end

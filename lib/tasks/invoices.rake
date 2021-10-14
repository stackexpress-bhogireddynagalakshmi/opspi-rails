namespace :invoices do
  desc "Generate invoice for each user subscriptions"
  task generate_invoices: :environment do
    Account.all.each do |account|
      next if account.admin_tenant?
      account.users.each do |user|
        next unless user.subscriptions.any?
        user.subscriptions.each do |subscription|
          InvoiceManager::InvoiceCreator.new(subscription).call
        end
      end
    end
  end


  desc "Auto Debit for the unpaid invoices"
  task  auto_payment: :environment do
    Account.all.each do |account|
      next if account.admin_tenant?
      account.users.each do |user|
        next unless user.subscriptions.any?
        user.subscriptions.each do |subscription|
          invoice = subscription.current_unpaid_invoice
            InvoiceManager::InvoiceAutoDebiter.new(invoice).call  if invoice.present?
        end
      end
    end
  end


  desc "Disbale Pannel access on non payement of invoice after grace Period"
  task  disbale_account: :environment do
    Account.all.each do |account|
      next if account.admin_tenant?
      account.users.each do |user|
        next unless user.subscriptions.any?
        user.subscriptions.each do |subscription|
          invoice = subscription.current_unpaid_invoice
          InvoiceManager::AccountGracePeriodChecker.new(invoice) if invoice.present?
        end
      end
    end
  end
end


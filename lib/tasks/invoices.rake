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


  desc "Disbale Pannel access on non payment of invoice after grace Period"
  task  disable_control_panel: :environment do
    Account.all.each do |account|
      next if account.admin_tenant?
      account.users.each do |user|
        next unless user.subscriptions.any?
        user.subscriptions.each do |subscription|
          invoice = subscription.current_unpaid_invoice
          InvoiceManager::InvoiceGracePeriodChecker.new(invoice).call if invoice.present?
        end
      end
    end
  end


  desc "Enable Pannel access on successful payment of invoices"
  task  enable_control_panel: :environment do
    Account.all.each do |account|
      next if account.admin_tenant?
      account.users.each do |user|
        next unless user.subscriptions.any?
        user.subscriptions.each do |subscription|
         
          if subscription.control_panel_disabled? && subscription.invoices.active.count == 0
            AppManager::PanelAccessEnabler.new(subscription.invoices.last).call
          end

        end
      end
    end
  end
end


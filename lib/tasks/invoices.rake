namespace :invoices do
  desc "Generate invoice for each user subscriptions"
  task generate_invoices: :environment do
    Account.all.each do |account|
      next if account.admin_tenant?
      account.users.each do |user|
        next unless user.subscriptions.any?
        user.subscriptions.each do |subscription|
          InvoiceManager::InvoiceCreator.new(subscription).call if subscription.canceled_at.blank?
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
          subscription.invoices.active.each do |invoice|
            InvoiceManager::InvoiceAutoDebiter.new(invoice).call 
          end
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
          invoice = subscription.invoices.active.first
          pending_invoice = subscription.invoices.active.pluck(:invoice_number)
          InvoiceManager::InvoiceGracePeriodChecker.new(invoice,pending_invoice).call if invoice.present?
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


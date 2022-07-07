namespace :quota_usages do
  desc "Update quota usage"
  task update_quota_usage: :environment do
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
end
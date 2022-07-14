namespace :quota_usages do
  desc "Update quota usage"
  task update_quota_usage: :environment do
    Account.all.each do |account|
      next if account.admin_tenant?
      account.users.each do |user|
        next unless user.subscriptions.any?
        user.subscriptions.active.each do |subscription|
          IspQuotaManager::IspQuotaCalculator.new(subscription).call 
        end
      end
    end
  end
end
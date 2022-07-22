# frozen_string_literal: true

class HostedZone < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'
  has_many   :hosted_zone_records
  belongs_to :user_domain, dependent: :destroy

  after_commit :ensure_user_domain_updated, on: [:create]

  def ensure_user_domain_updated
    user_domain = user.user_domains.where(domain: name).last
    return nil if user_domain.blank?

    user_domain.update_column(:success, true)
    self.update_column(:user_domain_id, user_domain.id)
  end
end

# frozen_string_literal: true

class HostedZone < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'
  has_many :hosted_zone_records

  after_commit :ensure_user_domain_updated, on: [:create]


  def ensure_user_domain_updated
    user_domain = user.user_domains.where(domain: name).last
    return nil if user_domain.blank?

    user_domain.update_column(:success, true)
    user_domain.update_column(:hosted_zone_id , id)
  end

end

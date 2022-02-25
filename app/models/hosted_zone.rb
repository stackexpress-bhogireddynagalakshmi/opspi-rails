# frozen_string_literal: true

class HostedZone < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'
  has_many :hosted_zone_records
end

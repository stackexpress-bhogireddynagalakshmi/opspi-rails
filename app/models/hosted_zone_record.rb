# frozen_string_literal: true

class HostedZoneRecord < ApplicationRecord
  belongs_to :hosted_zone
end

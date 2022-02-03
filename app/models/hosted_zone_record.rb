class HostedZoneRecord < ApplicationRecord
    belongs_to :hosted_zone
    require 'isp_config/hosted_zone_record'
    delegate :user, to: :hosted_zone

end

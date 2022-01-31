class HostedZone < ApplicationRecord
  belongs_to :user,:class_name=>'Spree::User'
  has_many :hosted_zone_records
  require 'isp_config/hosted_zone'
  # after_create_commit :ensure_hosted_zone_added_to_ispconfig

  # def ensure_hosted_zone_added_to_ispconfig
  #   zone = IspConfig::HostedZone.new(self).create
  # end
    
end

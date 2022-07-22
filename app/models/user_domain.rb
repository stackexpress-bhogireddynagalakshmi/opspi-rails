class UserDomain < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User',foreign_key: 'user_id'
  has_one :hosted_zone

  validates :domain, presence: true
  after_create_commit :ensure_panel_id_is_set

  enum web_hosting_type: {
    windows: 0,
    linux: 1
  }

  private
  def ensure_panel_id_is_set
    return nil unless panel_id.blank?

    update_column(:panel_id, user.panel_config["dns"]) 
  end
end

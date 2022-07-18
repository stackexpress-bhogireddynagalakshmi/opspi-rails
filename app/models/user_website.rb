class UserWebsite < ApplicationRecord

  belongs_to :user, class_name: 'Spree::User',foreign_key: 'user_id'
  belongs_to :user_domain

  after_create_commit :ensure_panel_id_is_set


  private
  def ensure_panel_id_is_set
    return nil unless panel_id.blank?

    if user_domain.windows?
      update_column(:panel_id, user.panel_config["web_windows"]) 
    else
      update_column(:panel_id, user.panel_config["web_linux"]) 
    end
  end
end

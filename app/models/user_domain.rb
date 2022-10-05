class UserDomain < ApplicationRecord
  include PanelConfiguration
  
  belongs_to :user, class_name: 'Spree::User',foreign_key: 'user_id'
  has_one :user_website, class_name: 'UserWebsite'
  has_one :user_mail_domain
  has_many :user_mailboxes
  has_many :user_mailing_lists
  has_many :user_mail_forwards
  has_many :user_spam_filters
  has_many :user_ftp_users
  has_many :user_databases

  has_one :hosted_zone

  validates :domain, presence: true
  after_create_commit :ensure_panel_id_is_set

  enum web_hosting_type: {
    windows: 0,
    linux: 1
  }


  def nameserver1
   config_value_for(user.panel_config["dns"], 'ISPCONFIG_DNS_SERVER_NS1')
  end

  def nameserver2
   config_value_for(user.panel_config["dns"], 'ISPCONFIG_DNS_SERVER_NS2')
  end

  def remote_folder_path
    if windows?
      "\\#{domain}\\wwwroot"
    else
      # TODO: Yet to be implemented
    end
  end

  private

  def ensure_panel_id_is_set
    return nil unless panel_id.blank?

    update_column(:panel_id, user.panel_config["dns"]) 
  end

end

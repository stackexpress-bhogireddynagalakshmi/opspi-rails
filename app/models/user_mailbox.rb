class UserMailbox < ApplicationRecord
  include PanelConfiguration
  belongs_to :user_domain
  delegate :user, to: :user_domain

    def self.mail_box_count(user,server_type)
      self.where(user_domain_id: UserDomain.where(user_id: user.id,web_hosting_type: server_type)).count
    end

   def pop
    config_value_for(user.panel_config["mail"], 'MAIL_SERVER_POP_URL')
   end

   def smtp
    config_value_for(user.panel_config["mail"], 'MAIL_SERVER_SMTP_URL')
   end

   def imap
    config_value_for(user.panel_config["mail"], 'MAIL_SERVER_IMAP_URL')
   end

   def webmail_url
     config_value_for(user.panel_config["mail"], 'WEBMAIL_URL')
   end
end

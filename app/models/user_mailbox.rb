class UserMailbox < ApplicationRecord
  include PanelConfiguration
  belongs_to :user_domain
  delegate :user, to: :user_domain

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

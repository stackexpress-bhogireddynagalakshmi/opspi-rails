class UserFtpUser < ApplicationRecord
  include PanelConfiguration

  belongs_to :user_domain
  delegate :user , to: :user_domain

  def self.ftp_user_count(user,server_type)
    self.where(user_domain_id: UserDomain.where(user_id: user.id,web_hosting_type: server_type)).count
  end

  def host
    if user_domain.windows?
      config_value_for(user.panel_config["web_windows"], 'FTP_SERVER_HOSTNAME')
    else
      config_value_for(user.panel_config["web_linux"], 'FTP_SERVER_HOSTNAME')
    end
  end

  def port
      if user_domain.windows?
      config_value_for(user.panel_config["web_windows"], 'FTP_SERVER_PORT')
    else 
      config_value_for(user.panel_config["web_linux"], 'FTP_SERVER_PORT')
    end
  end

end

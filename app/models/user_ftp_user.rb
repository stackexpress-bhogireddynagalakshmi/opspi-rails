class UserFtpUser < ApplicationRecord
  include PanelConfiguration

  belongs_to :user_domain
  delegate :user , to: :user_domain

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

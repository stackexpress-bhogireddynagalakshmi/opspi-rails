class UserFtpUser < ApplicationRecord
  include PanelConfiguration

  belongs_to :user_domain
  delegate :user , to: :user_domain


  def hostname
    if user_domain.windows?
      config_value_for(user.panel_config["web_windows"], 'FTP_SERVER_WINDOWS_HOSTNAME')
    else ms_sql2019?
      config_value_for(user.panel_config["web_linux"], 'FTP_SERVER_LINUX_HOSTNAME')
    end
  end

end

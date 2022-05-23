module ApisHelper
  extend ActiveSupport::Concern

  def mail_user_api
    current_spree_user.isp_config.mail_user
  end

  def ftp_user_api
    current_spree_user.isp_config.ftp_user
  end

end

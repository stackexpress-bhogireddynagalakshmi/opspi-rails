module ApisHelper
  extend ActiveSupport::Concern

  def mail_user_api
    current_spree_user.isp_config.mail_user
  end

  def ftp_user_api
    if params[:server_type] == 'linux'
      current_spree_user.isp_config.ftp_user
    else
      current_spree_user.solid_cp.ftp_account
    end
  end

  def db_user_api
    current_spree_user.isp_config.database
  end

  def mail_domain_api
    current_spree_user.isp_config.mail_domain
  end

  def host_zone_api
    current_spree_user.isp_config.hosted_zone
  end

  def host_zone_record_api
    current_spree_user.isp_config.hosted_zone_record
  end

  def isp_website_api
    current_spree_user.isp_config.website
  end
end

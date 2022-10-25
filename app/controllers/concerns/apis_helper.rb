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
  alias dns_api host_zone_api

  def host_zone_record_api
    current_spree_user.isp_config.hosted_zone_record
  end

  def isp_website_api
    current_spree_user.isp_config.website
  end

  def mailing_list_api
    current_spree_user.isp_config.mailing_list
  end

  def spamfilter_api(spam_filter)
    if spam_filter&.persisted? && spam_filter.wb == 'B'
      current_spree_user.isp_config.spam_filter_blacklist
    else
      current_spree_user.isp_config.spam_filter_whitelist
    end
  end

  def mail_forward_api
    current_spree_user.isp_config.mail_forward
  end
end

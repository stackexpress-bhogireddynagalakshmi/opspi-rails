class ProductConfig < ApplicationRecord
  belongs_to :product, class_name: 'Spree::Product', foreign_key: 'product_id'
  attr_accessor :product,:linux_limits,:windows_limits

  def after_initialize(product,linux_limits,windows_limits)
    @product = product
    @linux_limits = linux_limits
    @windows_limits = windows_limits
    # byebug
    # super()
  end

  def call
    create
  end

  # def product_config
  #   {
  #     name: product["name"],
  #     services: {
  #       domain:{
  #         domain_count_limit: @linux_limits.limit_dns_zone
  #       },
  #       dns: {
  #         enabled: true,
  #         dns_zones_count_limit: 10,  ##copy from domain_count_limit (default)
  #         default_secondary_dns_server: 0,
  #         secondary_dns_zones_count_limit: 10,
  #         dns_records_count_limit: 100,
  #         min_ttl_allowed: 300
  #       },
  #       mail: {
  #         enabled: true,
  #         mail_domains_count_limit: 10,  #copy from domain_count_limit (default)
  #         mailbox_count_limit: 25,
  #         email_aliases_count_limit: 10,
  #         domain_aliases_count_limit: 10,
  #         mailing_list_count_limit: 15,
  #         email_forwarders_count_limit: 10,
  #         email_catchall_accounts_count_limit: 10,
  #         email_routes_count_limit: 10,
  #         email_filters_count_limit: 10,
  #         fetchmail_accounts_count_limit: 10,
  #         mailbox_size_quota_count_limit: 5000,
  #         spamfilter_white_blacklist_filters_count_limit: 10,
  #         spamfilter_users_count_limit: 10,
  #         spamfilter_policies_count_limit: 10
    
  #       },
  #       database_mysql: {
  #         enabled: true,
  #         database_count_limit: 10,
  #         database_users_count_limit: 10,
  #         database_quota_size_quota: 5000    
  #       },
  #       database_mssql: {
  #         enabled: product["server_type"] == 'windows' ? true : false,
  #         database_count_limit: 5    
  #       },
  #       web_linux: {
  #         enabled: true,
  #         web_domains_count_limit: 10,  /#copy from domain_count_limit (default)
  #         disk_size_quota: 5000,
  #         traffic_quota: 5000,
  #         cgi_available: true,
  #         ssi_available: true,
  #         perl_available: true,
  #         ruby_available: true,
  #         python_available: true,
  #         SuEXEC_forced: true,
  #         custom_error_docs_available: true,
  #         Wildcard_subdomain_available: true,
  #         ssl_available: true,
  #         lets_encrypt_available: true,
  #         web_aliasdomains_count_limit: 10,
  #         web_subdomains_count_limit: 10,
  #         ftp_users_count_limit: 10,
  #         shell_users_count_limit: 0,
  #         webdav_users_count_limit: 0    
  #       },
  #       cron: {
  #         enabled: true,
  #         cron_jobs_count_limit: 10,
  #         type_of_cron_jobs_count_limit: 10,
  #         min_delay_between_executions_count_limit: 10
  #       },    
  #       web_windows: {
  #         enabled: product["server_type"] == 'windows' ? true : false,
  #         web_domains_count_limit: 10, #copy from domain_count_limit (default)
  #         ssl_allowed: true,
  #         disk_size_limit: 5000    
  #       }
  #     }
  #   }
  # end

  # def limit_dns_zone
  #   product["server_type"] == 'linux' ? linux_limits.limit_dns_zone : windows_limits.limit_dns_zone
  # end

  def create
    product_type = (product["server_type"] == 'reseller_plan') ? 'reseller_shared_hosting_plan' : 'enduser_shared_hosting_plan'
    @product_config = ProductConfig.create!({
                                name: product["name"],
                                configs: nil,
                                product_type: product_type,
                                status: 'active'
                                })
  end
end

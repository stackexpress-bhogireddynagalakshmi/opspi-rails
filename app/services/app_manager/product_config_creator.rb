# frozen_string_literal: true

module AppManager
  class ProductConfigCreator < ApplicationService
    attr_accessor :product,:linux_limits,:windows_limits

    def initialize(product, linux_limits, windows_limits)
      @product = product
      @linux_limits = linux_limits
      @windows_limits = windows_limits
    end

    def call
      create
    end

    def product_config
      {
        name: product["name"],
        services: {
          domain:{
            domain_count_limit: linux? ? linux_limits["limit_dns_zone"] : windows_attributes("OS.Domains", "quota_value")
          },
          dns: {
            enabled: true,
            dns_zones_count_limit: linux? ? linux_limits["limit_dns_zone"] : windows_attributes("OS.Domains", "quota_value"),  ##copy from domain_count_limit (default)
            default_secondary_dns_server: linux? ? linux_limits["default_slave_dnsserver"] : nil,
            secondary_dns_zones_count_limit: linux? ? linux_limits["limit_dns_slave_zone"] : windows_attributes("OS.SubDomains", "quota_value"),
            dns_records_count_limit: linux? ? linux_limits["limit_dns_record"] : nil,
            # min_ttl_allowed: 300
          },
          mail: {
            enabled: true,
            mail_domains_count_limit: linux? ? linux_limits["limit_dns_zone"] : windows_attributes("OS.Domains", "quota_value"),  #copy from domain_count_limit (default)
            mailbox_count_limit: linux? ? linux_limits["limit_mailbox"] : windows_attributes("Mail.MaxBoxSize", "quota_value"),
            email_aliases_count_limit: linux? ? linux_limits["limit_mailalias"] : nil,
            domain_aliases_count_limit: linux? ? linux_limits["limit_mailaliasdomain"] : nil,
            mailing_list_count_limit: linux? ? linux_limits["limit_mailmailinglist"] : windows_attributes("Mail.Lists", "quota_value"),
            email_forwarders_count_limit: linux? ? linux_limits["limit_mailforward"] : windows_attributes("Mail.Forwardings", "quota_value"),
            email_catchall_accounts_count_limit: linux? ? linux_limits["limit_mailcatchall"] : nil,
            email_routes_count_limit: linux? ? linux_limits["limit_mailrouting"] : nil,
            email_filters_count_limit: linux? ? linux_limits["limit_mailfilter"] : nil,
            fetchmail_accounts_count_limit: linux? ? linux_limits["limit_fetchmail"] : nil,
            mailbox_size_quota_count_limit: linux? ? linux_limits["limit_mailquota"] : nil,
            spamfilter_white_blacklist_filters_count_limit: linux? ? linux_limits["limit_spamfilter_wblist"] : nil,
            spamfilter_users_count_limit: linux? ? linux_limits["limit_spamfilter_user"] : nil,
            spamfilter_policies_count_limit: linux? ? linux_limits["limit_spamfilter_policy"] : nil,
            groups: linux? ? nil : windows_attributes("Mail.Groups", "quota_value"),
            max_group_members: linux? ? nil : windows_attributes("Mail.MaxGroupMembers", "quota_value"),
            max_list_members: linux? ? nil : windows_attributes("Mail.MaxListMembers", "quota_value")
          },
          database_mysql: {
            enabled: true,
            database_count_limit: linux? ? linux_limits["limit_database"] : windows_attributes("MySQL8.Databases", "quota_value"),
            database_users_count_limit: linux? ? linux_limits["limit_database_user"] : windows_attributes("MySQL8.Users", "quota_value"),
            database_quota_size_quota: linux? ? linux_limits["limit_database_quota"] : windows_attributes("MySQL8.MaxDatabaseSize", "quota_value")
          },
          database_mssql: {
            enabled: windows?,
            database_count_limit: windows? ? windows_attributes("MsSQL2019.Databases", "quota_value") : nil ,
            database_users_count_limit: windows? ? windows_attributes("MsSQL2019.Users", "quota_value") : nil,
            database_quota_size_quota: windows? ? windows_attributes("MsSQL2019.MaxDatabaseSize", "quota_value") : nil,
            database_max_log_size: windows? ? windows_attributes("MsSQL2019.MaxLogSize", "quota_value") : nil

          },
          web_linux: {
            enabled: linux?,
            web_domains_count_limit: linux? ? linux_limits["limit_dns_zone"] : nil,  #copy from domain_count_limit (default)
            disk_size_quota: linux? ? linux_limits["limit_web_quota"] : nil,
            traffic_quota: linux? ? linux_limits["limit_traffic_quota"] : nil,
            cgi_available: linux? ? linux_limits["limit_cgi"] : nil,
            ssi_available: linux? ? linux_limits["limit_ssi"] : nil,
            perl_available: linux? ? linux_limits["limit_perl"] : nil,
            php_available: linux? ? linux_limits["web_php_options"] : nil,
            ruby_available: linux? ? linux_limits["limit_ruby"] : nil,
            python_available: linux? ? linux_limits["limit_python"] : nil,
            SuEXEC_forced: linux? ? linux_limits["force_suexec"] : nil,
            custom_error_docs_available: linux? ? linux_limits["limit_hterror"] : nil,
            Wildcard_subdomain_available: linux? ? linux_limits["limit_wildcard"] : nil,
            ssl_available: linux? ? linux_limits["limit_ssl"] : nil,
            lets_encrypt_available: linux? ? linux_limits["limit_ssl_letsencrypt"] : nil,
            web_aliasdomains_count_limit: linux? ? linux_limits["limit_web_aliasdomain"] : nil,
            web_subdomains_count_limit: linux? ? linux_limits["limit_web_subdomain"] : nil,
            ftp_users_count_limit: linux? ? linux_limits["limit_ftp_user"] : nil,
            shell_users_count_limit: linux? ? linux_limits["limit_shell_user"] : nil,
            webdav_users_count_limit: linux? ? linux_limits["limit_webdav_user"] : nil    
          },
          cron: {
            enabled: linux?,
            cron_jobs_count_limit: linux? ? linux_limits["limit_cron"] : nil,
            type_of_cron_jobs_count_limit: linux? ? linux_limits["limit_cron_type"] : nil,
            min_delay_between_executions_count_limit: linux? ? linux_limits["limit_cron_frequency"] : nil
          },
          web_windows: {
            enabled: windows?,
            web_domains_count_limit: windows? ? windows_attributes("OS.Domains", "quota_value") : nil, #copy from domain_count_limit (default)
            web_app_gallery: windows? ? windows_attributes("Web.WebAppGallery", "enabled") : nil,
            asp: windows? ? windows_attributes("Web.Asp", "enabled") : nil,
            asp_net_11: windows? ? windows_attributes("Web.AspNet11", "enabled") : nil,
            asp_net_40: windows? ? windows_attributes("Web.AspNet20", "enabled") : nil,
            asp_net_20: windows? ? windows_attributes("Web.AspNet40", "enabled") : nil,
            php_4: windows? ? windows_attributes("Web.Php4", "enabled") : nil,
            php_5: windows? ? windows_attributes("Web.Php5", "enabled") : nil,
            perl_available: windows? ? windows_attributes("Web.Perl", "enabled") : nil ,
            python_available: windows? ? windows_attributes("Web.Python", "enabled") : nil,
            cgi_available: windows? ? windows_attributes("Web.CgiBin", "enabled") : nil,
            secured_folders: windows? ? windows_attributes("Web.SecuredFolders", "enabled") : nil,
            shared_ssl: windows? ? windows_attributes("Web.SharedSSL", "quota_value") : nil,
            redirections: windows? ? windows_attributes("Web.Redirections", "enabled") : nil,
            home_folders: windows? ? windows_attributes("Web.HomeFolders", "enabled") : nil,
            virtual_dirs: windows? ? windows_attributes("Web.VirtualDirs", "enabled") : nil,
            htaccess: windows? ? windows_attributes("Web.Htaccess", "enabled") : nil,
            front_page: windows? ? windows_attributes("Web.FrontPage", "enabled") : nil,
            security: windows? ? windows_attributes("Web.Security", "enabled") : nil,
            default_docs: windows? ? windows_attributes("Web.DefaultDocs", "enabled") : nil,
            app_pools: windows? ? windows_attributes("Web.AppPools", "enabled") : nil,
            app_pools_restart: windows? ? windows_attributes("Web.AppPoolsRestart", "enabled") : nil,
            headers: windows? ? windows_attributes("Web.Headers", "enabled") : nil,
            errors: windows? ? windows_attributes("Web.Errors", "enabled") : nil,
            mime: windows? ? windows_attributes("Web.Mime", "enabled") : nil,
            cold_fusion: windows? ? windows_attributes("Web.ColdFusion", "enabled") : nil,
            cf_virtual_directories: windows? ? windows_attributes("Web.CFVirtualDirectories", "enabled") : nil,
            ip_addresses: windows? ? windows_attributes("Web.IPAddresses", "quota_value") : nil,
            remote_management: windows? ? windows_attributes("Web.RemoteManagement", "enabled") : nil,
            ssl_allowed: windows? ? windows_attributes("Web.SSL", "enabled") : nil,
            allow_ip_address_mode_switch: windows? ? windows_attributes("Web.AllowIPAddressModeSwitch", "enabled") : nil,
            enable_host_name_support: windows? ? windows_attributes("Web.EnableHostNameSupport", "enabled") : nil,
            ftp_users_count_limit: windows? ? windows_attributes("FTP.Accounts", "quota_value") : nil
          }
        }
      }
    end


    def windows_attributes(name, value)
      return nil if linux?

      windows_limits.collect{|x| x["#{value}"] if x["quota_name"] == name}.compact.first
    end

    def linux?
      product["server_type"] == 'linux'
    end

    def windows?
      product["server_type"] == 'windows'
    end

    def create
    product_type = (product["server_type"] == 'reseller_plan') ? 'reseller_shared_hosting_plan' : 'enduser_shared_hosting_plan'
    @product_config = ProductConfig.create!({
                              name: product.name,
                              configs: product_config,
                              product_type: product_type,
                              status: 'active',
                              product_id: product.id,
                              store_id: product&.account&.store_id
                              })
    end

  end
end
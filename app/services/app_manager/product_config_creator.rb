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
            domain_count_limit: linux? ? linux_limits["limit_dns_zone"] : windows_domain_limit
          },
          dns: {
            enabled: true,
            dns_zones_count_limit: linux? ? linux_limits["limit_dns_zone"] : windows_domain_limit,  ##copy from domain_count_limit (default)
            default_secondary_dns_server: linux? ? linux_limits["default_slave_dnsserver"] : nil,
            secondary_dns_zones_count_limit: linux? ? linux_limits["limit_dns_slave_zone"] : windows_sub_domain_limit,
            dns_records_count_limit: linux? ? linux_limits["limit_dns_record"] : nil,
            # min_ttl_allowed: 300
          },
          mail: {
            enabled: true,
            mail_domains_count_limit: linux? ? linux_limits["limit_dns_zone"] : windows_domain_limit,  #copy from domain_count_limit (default)
            mailbox_count_limit: linux? ? linux_limits["limit_mailbox"] : windows_mailbox_count_limit,
            email_aliases_count_limit: linux? ? linux_limits["limit_mailalias"] : nil,
            domain_aliases_count_limit: linux? ? linux_limits["limit_mailaliasdomain"] : nil,
            mailing_list_count_limit: linux? ? linux_limits["limit_mailmailinglist"] : windows_maillist_count_limit,
            email_forwarders_count_limit: linux? ? linux_limits["limit_mailforward"] : windows_mailforward_count_limit,
            email_catchall_accounts_count_limit: linux? ? linux_limits["limit_mailcatchall"] : nil,
            email_routes_count_limit: linux? ? linux_limits["limit_mailrouting"] : nil,
            email_filters_count_limit: linux? ? linux_limits["limit_mailfilter"] : nil,
            fetchmail_accounts_count_limit: linux? ? linux_limits["limit_fetchmail"] : nil,
            mailbox_size_quota_count_limit: linux? ? linux_limits["limit_mailquota"] : nil,
            spamfilter_white_blacklist_filters_count_limit: linux? ? linux_limits["limit_spamfilter_wblist"] : nil,
            spamfilter_users_count_limit: linux? ? linux_limits["limit_spamfilter_user"] : nil,
            spamfilter_policies_count_limit: linux? ? linux_limits["limit_spamfilter_policy"] : nil,
            groups: linux? ? nil : windows_mail_group_count_limit,
            max_group_members: linux? ? nil : windows_mail_max_group_mem_count_limit,
            max_list_members: linux? ? nil : windows_mail_max_list_mem_count_limit
          },
          database_mysql: {
            enabled: true,
            database_count_limit: linux? ? linux_limits["limit_database"] : windows_mysql_count_limit,
            database_users_count_limit: linux? ? linux_limits["limit_database_user"] : windows_mysql_user_count_limit,
            database_quota_size_quota: linux? ? linux_limits["limit_database_quota"] : windows_mysql_db_quota_limit
          },
          database_mssql: {
            enabled: windows?,
            database_count_limit: windows? ? windows_mssql_count_limit : nil ,
            database_users_count_limit: windows? ? windows_mssql_user_count_limit : nil,
            database_quota_size_quota: windows? ? windows_mssql_db_quota_limit : nil,
            database_max_log_size: windows? ? windows_mssql_log_quota_limit : nil

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
            web_domains_count_limit: windows? ? windows_website_count_limit : nil, #copy from domain_count_limit (default)
            web_app_gallery: windows? ? windows_web_app_gallery : nil,
            asp: windows? ? windows_web_asp : nil,
            asp_net_11: windows? ? windows_web_asp_11 : nil,
            asp_net_40: windows? ? windows_web_asp_40 : nil,
            asp_net_20: windows? ? windows_web_asp_20 : nil,
            php_4: windows? ? windows_web_php_4 : nil,
            php_5: windows? ? windows_web_php_5 : nil,
            perl_available: windows? ? windows_web_perl : nil ,
            python_available: windows? ? windows_web_python : nil,
            cgi_available: windows? ? windows_web_cgi : nil,
            secured_folders: windows? ? windows_web_secured_folders : nil,
            shared_ssl: windows? ? windows_web_shared_ssl : nil,
            redirections: windows? ? windows_web_redirections : nil,
            home_folders: windows? ? windows_web_home_folders : nil,
            virtual_dirs: windows? ? windows_web_vir_dir : nil,
            htaccess: windows? ? windows_web_htaccess : nil,
            front_page: windows? ? windows_web_front_page : nil,
            security: windows? ? windows_web_security : nil,
            default_docs: windows? ? windows_web_default_docs : nil,
            app_pools: windows? ? windows_web_app_pools : nil,
            app_pools_restart: windows? ? windows_web_app_pools_restart : nil,
            headers: windows? ? windows_web_headers : nil,
            errors: windows? ? windows_web_error : nil,
            mime: windows? ? windows_web_mime : nil,
            cold_fusion: windows? ? windows_web_cold_fusion : nil,
            cf_virtual_directories: windows? ? windows_web_cf_virtual_dirs : nil,
            ip_addresses: windows? ? windows_web_ip_addresses : nil,
            remote_management: windows? ? windows_web_remote_management : nil,
            ssl_allowed: windows? ? windows_web_ssl : nil,
            allow_ip_address_mode_switch: windows? ? windows_web_allow_ip_address : nil,
            enable_host_name_support: windows? ? windows_web_home_folders : nil,
            ftp_users_count_limit: windows? ? windows_ftp_acc_count_limit : nil
          }
        }
      }
    end

    def windows_website_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "Web.Sites"}.compact.first
    end

    def windows_web_app_gallery
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.WebAppGallery"}.compact.first
    end

    def windows_web_asp
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Asp"}.compact.first
    end

    def windows_web_asp_11
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.AspNet11"}.compact.first
    end

    def windows_web_asp_20
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.AspNet20"}.compact.first
    end

    def windows_web_asp_40
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.AspNet40"}.compact.first
    end

    def windows_web_php_4
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Php4"}.compact.first
    end

    def windows_web_php_5
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Php5"}.compact.first
    end

    def windows_web_perl
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Perl"}.compact.first
    end

    def windows_web_python
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Python"}.compact.first
    end

    def windows_web_cgi
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.CgiBin"}.compact.first
    end

    def windows_web_secured_folders
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.SecuredFolders"}.compact.first
    end

    def windows_web_secured_folders
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.SecuredFolders"}.compact.first
    end

    def windows_web_shared_ssl
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "Web.SharedSSL"}.compact.first
    end

    def windows_web_redirections
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Redirections"}.compact.first
    end

    def windows_web_home_folders
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.HomeFolders"}.compact.first
    end

    def windows_web_vir_dir
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.VirtualDirs"}.compact.first
    end

    def windows_web_htaccess
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Htaccess"}.compact.first
    end

    def windows_web_front_page
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.FrontPage"}.compact.first
    end

    def windows_web_security
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Security"}.compact.first
    end

    def windows_web_default_docs
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.DefaultDocs"}.compact.first
    end

    def windows_web_app_pools
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.AppPools"}.compact.first
    end

    def windows_web_app_pools_restart
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.AppPoolsRestart"}.compact.first
    end

    def windows_web_headers
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Headers"}.compact.first
    end

    def windows_web_error
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Errors"}.compact.first
    end

    def windows_web_mime
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.Mime"}.compact.first
    end

    def windows_web_cold_fusion
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.ColdFusion"}.compact.first
    end

    def windows_web_cf_virtual_dirs
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.CFVirtualDirectories"}.compact.first
    end

    def windows_web_remote_management
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.RemoteManagement"}.compact.first
    end

    def windows_web_ip_addresses
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "Web.IPAddresses"}.compact.first
    end

    def windows_web_ssl
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.SSL"}.compact.first
    end

    def windows_web_allow_ip_address
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.AllowIPAddressModeSwitch"}.compact.first
    end

    def windows_web_enable_hostname
      return nil if linux?
      windows_limits.collect{|x| x["enabled"] if x["quota_name"] == "Web.EnableHostNameSupport"}.compact.first
    end

    def windows_ftp_acc_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "FTP.Accounts"}.compact.first
    end

    def windows_mail_group_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "Mail.Groups"}.compact.first
    end

    def windows_mail_max_group_mem_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "Mail.MaxGroupMembers"}.compact.first
    end

    def windows_mail_max_list_mem_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "Mail.MaxListMembers"}.compact.first
    end

    def windows_mailbox_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "Mail.MaxBoxSize"}.compact.first
    end

    def windows_maillist_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "Mail.Lists"}.compact.first
    end

    def windows_mailforward_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "Mail.Forwardings"}.compact.first
    end

    def windows_mysql_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "MySQL8.Databases"}.compact.first
    end

    def windows_mysql_user_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "MySQL8.Users"}.compact.first
    end

    def windows_mysql_db_quota_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "MySQL8.MaxDatabaseSize"}.compact.first
    end

    def windows_mssql_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "MsSQL2019.Databases"}.compact.first
    end

    def windows_mssql_user_count_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "MsSQL2019.Users"}.compact.first
    end

    def windows_mssql_db_quota_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "MsSQL2019.MaxDatabaseSize"}.compact.first
    end

    def windows_mssql_log_quota_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "MsSQL2019.MaxLogSize"}.compact.first
    end

    def windows_domain_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "OS.Domains"}.compact.first
    end 

    def windows_sub_domain_limit
      return nil if linux?
      windows_limits.collect{|x| x["quota_value"] if x["quota_name"] == "OS.SubDomains"}.compact.first
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
                              store_id: product.account.store_id
                              })
    end

  end
end
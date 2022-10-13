# frozen_string_literal: true

module AppManager
  class ProductConfigCreator < ApplicationService
    attr_accessor :product, :resource

    def initialize(product, resource)
      byebug
      @product = product
      @resource = resource
    end

    def call
      create
    end

    def product_config
      {
        name: product.name,
        services: {
          domain:{
            domain_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_dns_zone"] : windows_attributes("OS.Domains", "quota_value")
          },
          dns: {
            enabled: true,
            dns_zones_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_dns_zone"] : windows_attributes("OS.Domains", "quota_value"),  ##copy from domain_count_limit (default)
            default_secondary_dns_server: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["default_slave_dnsserver"] : nil,
            secondary_dns_zones_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_dns_slave_zone"] : windows_attributes("OS.SubDomains", "quota_value"),
            dns_records_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_dns_record"] : nil
          },
          mail: {
            enabled: true,
            mail_domains_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_dns_zone"] : windows_attributes("OS.Domains", "quota_value"),  #copy from domain_count_limit (default)
            mailbox_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_mailbox"] : windows_attributes("Mail.MaxBoxSize", "quota_value"),
            email_aliases_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_mailalias"] : nil,
            domain_aliases_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_mailaliasdomain"] : nil,
            mailing_list_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_mailmailinglist"] : windows_attributes("Mail.Lists", "quota_value"),
            email_forwarders_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_mailforward"] : windows_attributes("Mail.Forwardings", "quota_value"),
            email_catchall_accounts_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_mailcatchall"] : nil,
            email_routes_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_mailrouting"] : nil,
            email_filters_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_mailfilter"] : nil,
            fetchmail_accounts_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_fetchmail"] : nil,
            mailbox_size_quota_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_mailquota"] : nil,
            spamfilter_white_blacklist_filters_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_spamfilter_wblist"] : nil,
            spamfilter_users_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_spamfilter_user"] : nil,
            spamfilter_policies_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_spamfilter_policy"] : nil
          },
          database_mysql: {
            enabled: true,
            database_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_database"] : windows_attributes("MySQL8.Databases", "quota_value"),
            database_users_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_database_user"] : windows_attributes("MySQL8.Users", "quota_value"),
            database_quota_size_quota: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_database_quota"] : windows_attributes("MySQL8.MaxDatabaseSize", "quota_value")
          },
          database_mssql: {
            enabled: windows_or_reseller?,
            database_count_limit: windows_or_reseller? ? windows_attributes("MsSQL2019.Databases", "quota_value") : nil ,
            database_users_count_limit: windows_or_reseller? ? windows_attributes("MsSQL2019.Users", "quota_value") : nil,
            database_quota_size_quota: windows_or_reseller? ? windows_attributes("MsSQL2019.MaxDatabaseSize", "quota_value") : nil,
            database_max_log_size: windows_or_reseller? ? windows_attributes("MsSQL2019.MaxLogSize", "quota_value") : nil

          },
          web_linux: {
            enabled: linux_or_reseller?,
            web_domains_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_dns_zone"] : nil,  #copy from domain_count_limit (default)
            disk_size_quota: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_web_quota"] : nil,
            traffic_quota: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_traffic_quota"] : nil,
            cgi_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_cgi"] : nil,
            ssi_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_ssi"] : nil,
            perl_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_perl"] : nil,
            php_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["web_php_options"] : nil,
            ruby_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_ruby"] : nil,
            python_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_python"] : nil,
            SuEXEC_forced: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["force_suexec"] : nil,
            custom_error_docs_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_hterror"] : nil,
            Wildcard_subdomain_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_wildcard"] : nil,
            ssl_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_ssl"] : nil,
            lets_encrypt_available: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_ssl_letsencrypt"] : nil,
            web_aliasdomains_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_web_aliasdomain"] : nil,
            web_subdomains_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_web_subdomain"] : nil,
            ftp_users_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_ftp_user"] : nil,
            shell_users_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_shell_user"] : nil,
            webdav_users_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_webdav_user"] : nil    
          },
          cron: {
            enabled: linux_or_reseller?,
            cron_jobs_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_cron"] : nil,
            type_of_cron_jobs_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_cron_type"] : nil,
            min_delay_between_executions_count_limit: linux_or_reseller? ? resource["product"]["isp_config_limit_attributes"]["limit_cron_frequency"] : nil
          },
          web_windows: {
            enabled: windows_or_reseller?,
            web_domains_count_limit: windows_or_reseller? ? windows_attributes("OS.Domains", "quota_value") : nil, #copy from domain_count_limit (default)
            web_app_gallery: windows_or_reseller? ? windows_attributes("Web.WebAppGallery", "enabled") : nil,
            asp: windows_or_reseller? ? windows_attributes("Web.Asp", "enabled") : nil,
            asp_net_11: windows_or_reseller? ? windows_attributes("Web.AspNet11", "enabled") : nil,
            asp_net_40: windows_or_reseller? ? windows_attributes("Web.AspNet20", "enabled") : nil,
            asp_net_20: windows_or_reseller? ? windows_attributes("Web.AspNet40", "enabled") : nil,
            php_4: windows_or_reseller? ? windows_attributes("Web.Php4", "enabled") : nil,
            php_5: windows_or_reseller? ? windows_attributes("Web.Php5", "enabled") : nil,
            perl_available: windows_or_reseller? ? windows_attributes("Web.Perl", "enabled") : nil ,
            python_available: windows_or_reseller? ? windows_attributes("Web.Python", "enabled") : nil,
            cgi_available: windows_or_reseller? ? windows_attributes("Web.CgiBin", "enabled") : nil,
            secured_folders: windows_or_reseller? ? windows_attributes("Web.SecuredFolders", "enabled") : nil,
            shared_ssl: windows_or_reseller? ? windows_attributes("Web.SharedSSL", "quota_value") : nil,
            redirections: windows_or_reseller? ? windows_attributes("Web.Redirections", "enabled") : nil,
            home_folders: windows_or_reseller? ? windows_attributes("Web.HomeFolders", "enabled") : nil,
            virtual_dirs: windows_or_reseller? ? windows_attributes("Web.VirtualDirs", "enabled") : nil,
            htaccess: windows_or_reseller? ? windows_attributes("Web.Htaccess", "enabled") : nil,
            front_page: windows_or_reseller? ? windows_attributes("Web.FrontPage", "enabled") : nil,
            security: windows_or_reseller? ? windows_attributes("Web.Security", "enabled") : nil,
            default_docs: windows_or_reseller? ? windows_attributes("Web.DefaultDocs", "enabled") : nil,
            app_pools: windows_or_reseller? ? windows_attributes("Web.AppPools", "enabled") : nil,
            app_pools_restart: windows_or_reseller? ? windows_attributes("Web.AppPoolsRestart", "enabled") : nil,
            headers: windows_or_reseller? ? windows_attributes("Web.Headers", "enabled") : nil,
            errors: windows_or_reseller? ? windows_attributes("Web.Errors", "enabled") : nil,
            mime: windows_or_reseller? ? windows_attributes("Web.Mime", "enabled") : nil,
            cold_fusion: windows_or_reseller? ? windows_attributes("Web.ColdFusion", "enabled") : nil,
            cf_virtual_directories: windows_or_reseller? ? windows_attributes("Web.CFVirtualDirectories", "enabled") : nil,
            ip_addresses: windows_or_reseller? ? windows_attributes("Web.IPAddresses", "quota_value") : nil,
            remote_management: windows_or_reseller? ? windows_attributes("Web.RemoteManagement", "enabled") : nil,
            ssl_allowed: windows_or_reseller? ? windows_attributes("Web.SSL", "enabled") : nil,
            allow_ip_address_mode_switch: windows_or_reseller? ? windows_attributes("Web.AllowIPAddressModeSwitch", "enabled") : nil,
            enable_host_name_support: windows_or_reseller? ? windows_attributes("Web.EnableHostNameSupport", "enabled") : nil,
            ftp_users_count_limit: windows_or_reseller? ? windows_attributes("FTP.Accounts", "quota_value") : nil
          }
        }
      }
    end


    def windows_attributes(name, value)
      return nil if linux?
      nil
      # resource["product"]["plan_quota_groups_attributes"][""]["plan_quotas_attributes"]["2"]["quota_value"]
    end

    def linux?
      product.server_type == 'linux'
    end

    def windows?
      product.server_type == 'windows'
    end

    def reseller_plan?
      product.server_type == 'reseller_plan'
    end

    def linux_or_reseller?
      linux? || reseller_plan?
    end

    def windows_or_reseller?
      windows? || reseller_plan?
    end

    def create
    product_type = reseller_plan? ? 'reseller_shared_hosting_plan' : 'enduser_shared_hosting_plan'
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
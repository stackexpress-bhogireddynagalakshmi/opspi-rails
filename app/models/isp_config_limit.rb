# frozen_string_literal: true

class IspConfigLimit < ApplicationRecord
  belongs_to :product, class_name: 'Spree::Product', foreign_key: 'product_id'

  FIELDS = {
    web_limits: [
      # web_servers[]: 1,
      { field: :limit_web_domain, type: :text_field, name: 'Max. number of web domains' },
      { field: :limit_web_quota, type: :text_field, name: 'Web Quota (MB)' },
      { field: :limit_traffic_quota, type: :text_field, name: 'Traffic Quota (MB)' },
      { field: :limit_cgi, type: :check_box, name: 'CGI available' },
      { field: :limit_ssi, type: :check_box, name: 'SSI available' },
      { field: :limit_perl, type: :check_box, name: 'Perl available' },
      { field: :web_php_options, type: :array, name: 'Php available',
        options:
        [
          { label: 'Disabled', type: :check_box, value: 'no', field: :disabled },
          { label: 'Fast-CGI', type: :check_box, value: 'fast-cgi', field: :fast_cgi },
          { label: 'Mod-PHP', type: :check_box, value: 'mod', field: :mod },
          { label: 'PHP-FPM', type: :check_box, value: 'php-fpm', field: :php_fpm }
        ] },

      { field: :limit_ruby, type: :check_box, name: 'Ruby available' },
      { field: :limit_python, type: :check_box, name: 'Python available' },
      { field: :force_suexec, type: :check_box, name: 'SuEXEC forced' },

      { field: :limit_hterror, type: :check_box, name: 'Custom error docs available' },
      { field: :limit_wildcard, type: :check_box, name: 'Wildcard subdomain available' },
      { field: :limit_ssl, type: :check_box, name: 'SSL available' },
      { field: :limit_ssl_letsencrypt, type: :check_box, name: "Let's Encrypt available" },

      { field: :limit_web_aliasdomain, type: :text_field, name: 'Max. number of web aliasdomains' },
      { field: :limit_web_subdomain, type: :text_field, name: 'Max. number of web subdomains' },
      { field: :limit_ftp_user, type: :text_field, name: 'Max. number of FTP users' },
      { field: :limit_shell_user, type: :text_field, name: 'Max. number of Shell users' },

      { field: :limit_webdav_user, type: :text_field, name: 'Max. number of Webdav users' }
    ],

    email_limits: [
      # mail_servers[]: 1,
      { field: :limit_maildomain, type: :text_field, name: "Max. number of email domains" },
      { field: :limit_mailbox, type: :text_field, name: "Max. number of mailboxes" },
      { field: :limit_mailalias, type: :text_field, name: "Max. number of email aliases" },
      { field: :limit_mailaliasdomain, type: :text_field, name: "Max. number of domain aliases" },
      { field: :limit_mailmailinglist, type: :text_field, name: "Max. number of mailing lists" },
      { field: :limit_mailforward, type: :text_field, name: "Max. number of email forwarders" },
      { field: :limit_mailcatchall, type: :text_field, name: "Max. number of email catchall accounts" },
      { field: :limit_mailrouting, type: :text_field, name: "Max. number of email routes" },
      { field: :limit_mailfilter, type: :text_field, name: "Max. number of email filters" },
      { field: :limit_fetchmail, type: :text_field, name: "Max. number of fetchmail accounts" },
      { field: :limit_mailquota, type: :text_field, name: "Mailbox quota (MB)" },
      { field: :limit_spamfilter_wblist, type: :text_field,
        name: "Max. number of spamfilter white / blacklist filters" },
      { field: :limit_spamfilter_user, type: :text_field, name: "Max. number of spamfilter users" },
      { field: :limit_spamfilter_policy, type: :text_field, name: "Max. number of spamfilter policies" }
    ],

    xmpp_limits: [
      { field: :limit_xmpp_domain, type: :text_field, name: "Max. number of XMPP domains" },
      { field: :limit_xmpp_user, type: :text_field, name: "Max. number of XMPP accounts" }
    ],

    database_limits: [
      { field: :limit_database, type: :text_field, name: "Max. number of Databases" },
      { field: :limit_database_user, type: :text_field, name: "Max. Database users" },
      { field: :limit_database_quota, type: :text_field, name: "Database quota (MB)" }
    ],

    cron_limits: [
      { field: :limit_cron, type: :text_field, name: "Max. number of cron jobs" },
      { field: :limit_cron_type, type: :text_field, name: "Max. type of cron jobs (chrooted and full implies url)" },
      { field: :limit_cron_frequency, type: :text_field, name: "Min. delay between executions" }
    ],

    dns_servers: [
      { field: :limit_dns_zone, type: :text_field, name: "Max. number of DNS zones" },
      { field: :default_slave_dnsserver, type: :text_field, name: "Default Secondary DNS Server" },
      { field: :limit_dns_slave_zone, type: :text_field, name: "Max. number of secondary DNS zones" },
      { field: :limit_dns_record, type: :text_field, name: "Max. number DNS records" }
    ],

    virtualization_limits: [
      { field: :limit_openvz_vm, type: :text_field, name: "Max. number of virtual servers" },
      { field: :limit_openvz_vm_template_id, type: :text_field, name: "Force virtual server template" }
    ],

    aps_installer_limit: [
      { field: :limit_aps, type: :text_field, name: "Max. number of APS instances" }
    ],

    limit_client: [
      { field: :limit_client, type: :text_field, name: "Max. number of Clients", visible_to_only_admin: true }
    ]
  }.freeze

  def self.get_fields_name
    column_names   # This might raise error during the migration or seed
  rescue StandardError => e
    Rails.logger.error { e.message }
  end
end

class CreateIspConfigLimits < ActiveRecord::Migration[6.1]
  def change
    create_table :isp_config_limits do |t|
      t.integer :product_id
      t.string :name

      t.integer :default_webserver,default: 1,null: false

      t.integer :limit_web_domain,	default: -1, null: false
      t.integer :limit_web_quota,	default: -1, null: false
      t.integer :limit_web_ip,	default: -1, null: false

      
	  t.integer :limit_traffic_quota,	default: -1, null: false
	  t.string  :web_php_options,	default: "no,fast-cgi,cgi,mod,suphp",null: false

	  t.boolean :limit_cgi, default: false,null: false
	  t.boolean :limit_ssi, default: false,null: false
	  t.boolean :limit_perl, default: false,null: false
	  t.boolean :limit_ruby, default: false,null: false
	  t.boolean :limit_python, default: false,null: false
	  t.boolean :limit_hterror, default: false,null: false
	  t.boolean :limit_wildcard, default: false,null: false
	  t.boolean :limit_ssl, default: false,null: false
	  t.boolean :limit_ssl_letsencrypt, default: false,null: false

	  t.boolean  :force_suexec,	default: true,null: false

	  t.integer :limit_web_aliasdomain,	default: -1, null: false
	  t.integer :limit_web_subdomain,	default: -1, null: false
	  t.integer :limit_ftp_user, default: -1, null: false
	  t.integer :limit_shell_user, default: 0, null: false
	  t.string :ssh_chroot, default: "no,jailkit,ssh-chroot", null: false
	  t.integer :limit_webdav_user,	default: 0, null: false

	  t.integer :default_mailserver,	default: 1, null: false 
	  t.integer :limit_maildomain,	default: -1, null: false
	  t.integer	:limit_mailbox,	default: -1, null: false
	  t.integer :limit_mailalias,	default: -1, null: false
	  t.integer :limit_mailaliasdomain,	default: -1, null: false
	  t.integer	:limit_mailmailinglist,	default: -1, null: false
	  t.integer :limit_mailforward,	default: -1, null: false
	  t.integer	:limit_mailcatchall,	default: -1, null: false
	  t.integer	:limit_mailrouting,	default: 0, null: false
	  t.integer	:limit_mailfilter, default: -1, null: false
	  t.integer	:limit_fetchmail,	default: -1, null: false
	  t.integer	:limit_mailquota,	default: -1, null: false
	  t.integer	:limit_spamfilter_wblist,	default: 0, null: false
	  t.integer	:limit_spamfilter_user,		default: 0, null: false
	  t.integer :limit_spamfilter_policy,	default: 0, null: false

	  t.integer :limit_xmpp_domain,	default: -1, null: false
	  t.integer	:limit_xmpp_user,	default: -1, null: false
	  
	  t.integer :default_dbserver,	default: 1, null: false
	  t.integer :limit_database,	default: -1, null: false
	  t.integer :limit_database_user,	default: -1, null: false
	  t.integer :limit_database_quota,	default: -1, null: false

	  t.integer :limit_cron,	default: 0, null: false
	  t.string  :limit_cron_type,	default: "url",null: false
	  t.integer :limit_cron_frequency,	default: 5, null: false

	  t.integer :limit_dns_zone,	default: -1, null: false
	  t.integer :default_slave_dnsserver,	default: 0, null: false
	  t.integer :limit_dns_slave_zone,	default: -1, null: false
	  t.integer :limit_dns_record,	default: -1, null: false
	
	  t.integer :limit_openvz_vm
	  t.integer :limit_openvz_vm_template_id
	  
	  t.integer :limit_client,default: 100,null:false

	  t.integer :limit_aps
      t.timestamps
    end
  end
end

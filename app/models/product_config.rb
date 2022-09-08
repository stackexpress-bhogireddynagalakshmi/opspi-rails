class ProductConfig < ApplicationRecord
  belongs_to :product, class_name: 'Spree::Product', foreign_key: 'product_id'
  attr_reader :product, :linux_limits, :windows_limits
  
  def initialize(product,linux_limits ={}, windows_limits ={})
    @product = product
    @linux_limits = linux_limits
    @windows_limits = windows_limits
    byebug
  end

  def call
    product_config_params = {
      name: @product.name,
      configs: product_config,
      product_type: @product.server_type == 'reseller_plan' ? 'reseller_shared_hosting_plan' : 'enduser_shared_hosting_plan',
      status: 'active'
    }
    
    create
    
  end

  def product_config
    {
      services: {
        domain:{
          domain_count_limit: @linux_limits.limit_dns_zone
        },
        dns: {
          records_count_limit: @linux_limits.limit_dns_record
        },
        mail: {
            mail_domain_count_limit: @linux_limits.limit_maildomain,
            mailbox_count_limit: @linux_limits.limit_mailbox,
            mailing_list_count_limit: @linux_limits.limit_mailmailinglist
        },
        database_mysql: {
            database_count_limit: @linux_limits.limit_dns_record
        },
        database_mssql: {
            database_count_limit: 5
        },
        web_linux: {
            ssl_allowed: true,
            disk_size_limit: @linux_limits.limit_dns_record
        },
        web_windows: {
            ssl_allowed: true,
            disk_size_limit: 5000
        },
        ftp_linux:  5,
        ftp_windows: 5,
    
        }
    }
  end

  def create
    
  end
end
    
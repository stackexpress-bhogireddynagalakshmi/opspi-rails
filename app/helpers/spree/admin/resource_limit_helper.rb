module Spree::Admin::ResourceLimitHelper
  
  def current_user_product
      TenantManager::TenantHelper.unscoped_query do
        current_spree_user.orders.collect do |o|
          o.products
        end.flatten
      end.compact
    end
  
    def resource_limit_check(server_type, domain_type)
      product = get_product(server_type)
      resource_limit = get_resource_limit(product)

      return true if resource_limit.nil?

      return @limit_exceed = domain_limit_exceed_check(resource_limit, server_type) if domain_type == 'domain'
      return @limit_exceed = mail_box_limit_exceed_check(resource_limit, server_type) if domain_type == 'mail_box'
      return @limit_exceed = ftp_limit_exceed_check(resource_limit, server_type) if domain_type == 'ftp_user'
    end

    def get_product(server_type)
      current_user_product.collect{|p| p if p.server_type == server_type }.compact.first
    end

    def get_resource_limit(product)
      product_config = ProductConfig.where(product_id: product.id).last
      product_config&.configs.try(:[],"services")
    end
  
    def domain_limit_exceed_check(resource_limit, server_type)
      limit = resource_limit["domain"]["domain_count_limit"].to_i
      used_count = current_spree_user.user_domains.collect{|x| x if x.web_hosting_type == server_type}.compact.count

      limit_count_check(used_count, limit)
    end

    def mail_box_limit_exceed_check(resource_limit, server_type)
      limit = resource_limit["mail"]["mailbox_count_limit"].to_i
      used_count =current_spree_user.user_domains.where(web_hosting_type: server_type).collect{|x| x.user_mailboxes.count}.compact.inject(0, :+)

      limit_count_check(used_count, limit)
    end

    def ftp_limit_exceed_check(resource_limit, server_type)
      limit = resource_limit["web_linux"]["enabled"] ? resource_limit["web_linux"]["ftp_users_count_limit"].to_i : resource_limit["web_windows"]["ftp_users_count_limit"].to_i
      used_count = UserFtpUser.ftp_user_count(current_spree_user,server_type)

      limit_count_check(used_count, limit)
    end

    def limit_count_check(used_count, limit)
      if limit_exceeded(used_count, limit) 
        return {success: true} 
      else
        return failed_response
      end
    end

    def limit_exceeded(current_value, limit)
      return true if limit == -1
      current_value >= limit ? false : true
    end

    def failed_response
      {success: false, message: I18n.t('spree.resource_limit_exceeds')}
    end
end

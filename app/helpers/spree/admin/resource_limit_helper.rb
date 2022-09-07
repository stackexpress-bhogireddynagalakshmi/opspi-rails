module Spree::Admin::ResourceLimitHelper
  
  def current_user_product
      TenantManager::TenantHelper.unscoped_query do
        current_spree_user.orders.collect do |o|
          o.products.find_by_server_type("linux")
        end.flatten
      end.compact.map(&:id).first
    end
  
    def get_linux_resource_limit
      IspConfigLimit.where(product_id: current_user_product).last
    end
  
    def current_plan_domain_limit
      get_linux_resource_limit&.limit_dns_zone
    end
  
    def current_plan_mail_box_limit
      get_linux_resource_limit&.limit_mailbox
    end
  
    def resource_limit_exceeded(resource)
      if resource == 'domain'
        current_spree_user.user_domains.count >= current_plan_domain_limit.to_i ? true : false
      elsif resource == 'mail_box'
        mail_box_limit >= current_plan_mail_box_limit.to_i ? true : false
      end    
    end
  
    def mail_box_limit
      current_spree_user.user_domains.collect do |u|
        UserMailbox.where(user_domain_id: u.id)
      end.flatten.compact.count
    end
  
    def resource_alert(res)
      if resource_limit_exceeded(res)
      I18n.t('spree.resource_limit_exceeds')
      end
    end
  
end
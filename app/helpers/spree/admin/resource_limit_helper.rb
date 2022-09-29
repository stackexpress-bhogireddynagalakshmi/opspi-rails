module Spree::Admin::ResourceLimitHelper
  
  def current_user_product
      TenantManager::TenantHelper.unscoped_query do
        current_spree_user.orders.collect do |o|
          o.products
        end.flatten
      end.compact
    end
  
    def domain_check(server_type)
      product = get_product(server_type)
      product_config = ProductConfig.where(product_id: product.id).last
      resource_limit = product_config.configs["services"]
      
      domain_limit_exceed_check(resource_limit, server_type)
    end

    def get_product(server_type)
      current_user_product.collect{|p| p if p.server_type == server_type }.compact.first
    end
  
    def domain_limit_exceed_check(resource_limit, server_type)
      limit = resource_limit["domain"]["domain_count_limit"].to_i
      used_count = current_spree_user.user_domains.collect{|x| x if x.web_hosting_type == server_type}.compact.count

      if limit_exceeded(used_count, limit) 
        return true 
      else
        flash[:warning] = I18n.t('spree.resource_limit_exceeds')
        return false
      end
    end

    def limit_exceeded(current_value, limit)
      return true if limit == -1
      current_value >= limit ? false : true
    end  
end

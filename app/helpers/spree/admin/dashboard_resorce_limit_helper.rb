module Spree::Admin::DashboardResorceLimitHelper

def current_user_product
    TenantManager::TenantHelper.unscoped_query{ current_spree_user.subscriptions.active.map(&:plan)}
end

def get_plan_details
    get_resource_limit(current_user_product.compact)
    
end

def get_resource_limit(product)
    @plan_quotas = []
    product.each do |p|
        @plan_quotas << ProductConfig.find_by(product_id: p.id)
    end
end


def get_domain_count(id)
    UserDomain.where(user_id: current_spree_user.id, web_hosting_type: Spree::Product.find_by(id: id).server_type).count
end

def get_mail_count(id)
    UserMailbox.mail_box_count(current_spree_user, Spree::Product.find_by(id: id).server_type)
end



def get_plan_quota(id, type, quota_fields)
    @plan_quotas.flatten.compact.each do |quota|
        if quota.product_id == id
        return  quota["configs"]["services"][type][quota_fields].to_i
        end
    end
end


end
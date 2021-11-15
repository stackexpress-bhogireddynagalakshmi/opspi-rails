module ApplicationHelper

  def get_spree_roles(user)
    if user.superadmin?
      Spree::Role.all
    elsif user.store_admin?
      Spree::Role.where(name: ['user'])
    end
  end

  def current_admin_tenant?
    TenantManager::TenantHelper.current_admin_tenant?
  end

  def render_new_tenant_information(order)
    text = ""
    if current_admin_tenant?
      user = TenantManager::TenantHelper.unscoped_query{order.user}
          text+=link_to user.account.domain,get_tenant_host_for_resource_path(user), target: '_blank'
      end
  end

  def plan_type_values(user)
    if user.superadmin?
      Spree::Product::server_types.keys
    elsif user.store_admin?
      TenantManager::TenantHelper.unscoped_query{current_spree_user.orders.collect{|o|o.products.pluck(:server_type)}.flatten}.uniq
    end
  end

  def current_tenant
    current_store.account || TenantManager::TenantHelper.current_tenant
  end

  def format_date(date)
    return unless date

    date.strftime("%m/%d/%y")
  end


  def current_available_payment_methods(user)
    if user.store_admin?
      TenantManager::TenantHelper.unscoped_query{TenantManager::TenantHelper.admin_tenant.payment_methods.available_on_front_end.select { |pm| pm.available_for_order?(self) }}
    else  
      current_tenant.payment_methods.available_on_front_end.select { |pm| pm.available_for_order?(self) }
    end
  end

  def link_to_with_protocol(text,url,opts={})
    protocol = request.ssl? ? 'https://' : 'http://'
    
    link_to text,"#{protocol}#{url}",opts
  end

  def render_domain_status(value)
    status = value["status"] == 'available' ?  "<span class='available'>Available</span>" : "<span class='not-available'>Not Available</span>"

    status.html_safe

  end

end

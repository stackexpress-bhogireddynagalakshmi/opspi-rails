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

  ### Need to add all the country codes ###
  def country_codes
    @countries = { "+93  Afghanistan" => "+93", "+355  Albania	" => "+355", "+213  Algeria	" => "+213", "+1 684 American Samoa" => "+1 684",
                   "+376 Andorra" => "+376", "+244 Angola" => "+244", "+1 264 Anguilla" => "+1 264", "+1 268 Antigua and Barbuda" => "+1 268",
                   "+54 Argentina" => "+54", "+374 Armenia" => "+374", "+297 Aruba" => "+297", "+247 Ascension" => "+247",
                   "+61 Australia" => "+61", "+672 1 Australian Antarctic Territory" => "+672 1", "+672 Australian External Territories" => "+672", "+43 Austria" => "+43",
                   "+994 Azerbaijan" => "+994", "+1 242 Bahamas" => "+1 242", "+973 Bahrain" => "+973", "+880 Bangladesh" => "+880",
                   "+1 246 Barbados" => "+1 246", "+1 268 Barbuda" => "+1 268", "+375 Belarus" => "+375", "+32 Belgium" => "+32",
                   "+501 Belize" => "+501", "+229 Benin" => "+229", "+1 441 Bermuda" => "+1 441", "+975 Bhutan" => "+975",
                   "+591 Bolivia" => "+591","+267 Botswana" => "+267", "+55 Brazil" => "+55","+673 Brunei" => "+673","+673 Bulgaria" => "+673", 
                   "+359 Burkina Faso " => "+359","+226 Burundi" => "+226",
                   "+855 Cambodia" => "+855","+237 Cameroon" => "+237","+238 Cape Verde" => "+238",
                   "+1 345 Cayman Islands" => "+1 345","+236 Central African Republic" => "+236","+235 Chad" => "+235","+56 Chile" => "+56",
                   "+86 China" => "+86","+61 Christmas Island" => "+61","+61 Cocos (Keeling) Islands" => "+61","+57 Colombia" => "+57",
                   "+269 Comoros" => "+269","+243 Congo(Brazzaville)" => "+243","+242 Congo(Kinshasa)" => "+242","+682 Cook Islands" => "+682",
                   "+506 Costa Rica" => "+506","+225 Cote D Ivoire" => "+225","+385 Croatia" => "+385","+53 Cuba" => "+53",
                   "+357 Cyprus" => "+357","+420 Czech Republic" => "+420","+45 Denmark" => "+45","+253 Djibouti " => "+253",
                   "+1 767 Dominica" => "+1 767","+1 809 Dominican Republic" => "+1 809","+358 Finland" => "+358","+33 France" => "+33",
                   "+995 Georgia" => "+995","+49 Germany" => "+49","+ 30 Greece" => "+ 30","+299 Greenland" => "+299",
                   "+852 Hong Kong" => "+852","+36 Hungary" => "+36","+354 Iceland" => "+354","+91 India" => "+91","+62 Indonesia" => "+62",
                   "+98 Iran" => "+98","+964 Iraq" => "+964","+353 Ireland" => "+353","+39 Italy" => "+39",
                   "+81 Japan" => "+81","+850 Korea, North" => "+850","+82 Korea, South" => "+82","+60 Malaysia" => "+60",
                   "+960 Maldives" => "+960","+230 Mauritius" => "+230","+52 Mexico" => "+52","+977 Nepal" => "+977",
                   "+47 Norway" => "+47","+968 Oman" => "+968","+92 Pakistan" => "+92","+974 Qatar" => "+974",
                   "+7 Russia" => "+7","+966 Saudi Arabia" => "+966","+65 Singapore" => "+65","+44 United Kingdom" => "+44","+1 United States" => "+1"}
  end


  def current_available_payment_methods(user)
    if user.present? && user.store_admin?
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

  def render_domain_name(product,line_item)
    return nil unless product.domain? 
    return nil unless line_item.domain.present?
    

    line_item.domain + ": #{line_item.validity} Years"
  end


  def generate_id_from_key(key)
    return nil  if key.blank?

    key.gsub('.','_')
  end

end

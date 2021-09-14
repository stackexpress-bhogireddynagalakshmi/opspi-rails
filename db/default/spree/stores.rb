#admin_tenant  = Account.find_or_create_by({domain: ENV['ADMIN_DOMAIN'],subdomain: ENV['ADMIN_DOMAIN']}) 


#dfault_store = TenantManager::TenantHelper.admin_tenant&.spree_store

default_store = Spree::Store.first


store_params = {
    default_country_id: Spree::Config[:default_country_id],
    name: 'OpsPI',
    code: 'opspi',
    url: ENV['ADMIN_DOMAIN'],
    mail_from_address: 'no-reply@example.com',
    customer_support_email: 'support@example.com',
    default_currency: 'USD',
    default_locale: I18n.locale,
    seo_title: 'OpsPi Demo Shop',
    meta_description: 'This is the new OpsPi UX DEMO | CONTACT',
    admin_email: 'admin@opspi.com',
    admin_password: ENV['ADMIN_PASSWORD']
  }

unless default_store.present?
  store = Spree::Store.new(store_params)
  store.save!
end
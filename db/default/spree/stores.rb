default_store = TenantManager::TenantHelper.admin_tenant&.spree_store

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
  sstore = Spree::Store.new(store_params)
  store.save!
end
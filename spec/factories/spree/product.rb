FactoryBot.define do
  factory :product, class: 'Spree::Product' do
    default_country_id {Spree::Config[:default_country_id]}
    name {'OpsPI'}
    code {SecureRandom.hex}
    url {"#{Random.new(42)}.example.com"}
    mail_from_address {'no-reply@example.com'}
    customer_support_email {'support@example.com'}
    default_currency {'USD'}
    default_locale {I18n.locale}
    seo_title {'OpsPi Demo Shop'}
    meta_description {'This is the new OpsPi UX DEMO | CONTACT'}
    admin_email {'admin@opspi.com'}
    admin_password {Devise.friendly_token.first(8)}
  end
end

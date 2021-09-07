Devise.setup do |config|
  # Required so users don't lose their carts when they need to confirm.
  config.allow_unconfirmed_access_for = 3.days

  # Fixes the bug where Confirmation errors result in a broken page.
  config.router_name = :spree
  config.secret_key = ENV['DEVISE_SECRET_KEY']

  #config.mailer = 'DeviseCustomMailer'

  # Add any other devise configurations here, as they will override the defaults provided by spree_auth_devise.
end
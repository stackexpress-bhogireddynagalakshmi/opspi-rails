ActionMailer::Base.smtp_settings = {
  domain:         ENV['ADMIN_DOMAIN'],
  address:        ENV['SMTP_HOST'],
  port:            ENV['SMTP_PORT'],
  authentication: :plain,
  user_name:       ENV["SMTP_USER"],
  password:       ENV["SMTP_PASS"],
  :authentication => :plain,
  :enable_starttls_auto => true
}
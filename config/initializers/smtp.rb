ActionMailer::Base.smtp_settings = {
  domain: 'test01.dev.opspi.com',
  address:        "smtp.mailgun.org",
  port:            587,
  authentication: :plain,
  user_name:       ENV["SMTP_USER"],
  password:       ENV["SMTP_PASS"],
  :authentication => :plain,
  :enable_starttls_auto => true
}
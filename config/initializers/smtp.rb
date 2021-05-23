ActionMailer::Base.smtp_settings = {
  domain: 'test01.dev.opspi.com',
  address:        "smtp.mailgun.org",
  port:            587,
  authentication: :plain,
  user_name:      'postmaster@sandbox43d2396794aa4fa288c9a9573c4e2f7b.mailgun.org',
  password:       '65fc99d064542ee06680cc5e633dadc2-a3d67641-cf8a98f8',
  :authentication => :plain,
  :enable_starttls_auto => true
}
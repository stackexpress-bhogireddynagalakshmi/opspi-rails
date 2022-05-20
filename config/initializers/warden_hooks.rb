Warden::Manager.after_set_user do |user,auth,opts|
  scope = opts[:scope]
  request = ActionDispatch::Request.new(auth.env)
  request.cookie_jar.signed["user.id"] = { value: user.id }
  request.cookie_jar.signed["user.expires_at"] = { value: 30.minutes.from_now }
end


Warden::Manager.before_logout do |user, auth, opts|
  scope = opts[:scope]
  auth.cookies.signed["user.id"] = nil
  auth.cookies.signed["user.expires_at"] = nil
end
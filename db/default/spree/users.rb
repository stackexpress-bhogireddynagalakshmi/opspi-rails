require 'highline/import'


# see last line where we create an admin if there is none, asking for email and password
def prompt_for_admin_password
  if ENV['ADMIN_PASSWORD']
    password = ENV['ADMIN_PASSWORD'].dup
    say "Admin Password #{password}"
  else
    randomPassword = Devise.friendly_token.first(8)
    password = ask("Password [#{randomPassword}]: ") do |q|
      q.echo = false
      q.validate = /^(|.{6,40})$/
      q.responses[:not_valid] = 'Invalid password. Must be at least 6 characters long.'
      q.whitespace = :strip
    end
    password = randomPassword if password.blank?
  end

  password
end

def prompt_for_admin_email
  if ENV['ADMIN_EMAIL']
    email = ENV['ADMIN_EMAIL'].dup
    say "Admin User #{email}"
  else
    email = ask('Email [opspi@example.com]: ') do |q|
      q.echo = true
      q.whitespace = :strip
    end
    email = 'opspi@example.com' if email.blank?
  end

  email
end

def create_admin_user
  if ENV['AUTO_ACCEPT']
    password = ENV['ADMIN_PASSWORD']
    email = 'opspi@example.com'
  else
    puts 'Create the admin user (press enter for defaults).'
    # name = prompt_for_admin_name unless name
    email = prompt_for_admin_email
    password = prompt_for_admin_password
  end
  attributes = {
    password: password,
    password_confirmation: password,
    email: email,
    login: email,
    account_id: 1,
    terms_and_conditions: true
  }

  load 'spree/user.rb'

  if Spree::User.find_by_email(email)
    say "\nWARNING: There is already a user with the email: #{email}, so no account changes were made.  If you wish to create an additional admin user, please run rake spree_auth:admin:create again with a different email.\n\n"
  else
    admin = Spree::User.new(attributes)
    if admin.save
      role = Spree::Role.find_or_create_by(name: 'admin')
      admin.spree_roles << role if !admin.spree_roles.include?(role)
      admin.save
      admin.confirm
      admin.generate_spree_api_key! if Spree::Auth::Engine.api_available?
      say "Done!"
    else
      say "There was some problems with persisting new admin user:"
      admin.errors.full_messages.each do |error|
        say error
      end
    end
  end
end


class UserMailForward < ApplicationRecord

  def self.mail_forward_count(user,server_type)
    self.where(user_domain_id: UserDomain.where(user_id: user.id,web_hosting_type: server_type)).count
  end
end

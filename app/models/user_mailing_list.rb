class UserMailingList < ApplicationRecord
  belongs_to :user_domain

  #deletegate :user, to: :user_domain
  def self.mailing_list_count(user,server_type)
    self.where(user_domain_id: UserDomain.where(user_id: user.id,web_hosting_type: server_type)).count
  end
end

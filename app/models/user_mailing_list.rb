class UserMailingList < ApplicationRecord
  belongs_to :user_domain

  #deletegate :user, to: :user_domain
end

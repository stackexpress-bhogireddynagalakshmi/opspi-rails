class UserWebsite < ApplicationRecord
  belongs_to :user_domain

  enum hosting_type: {
    windows: 1,
    linux: 2
  }
end

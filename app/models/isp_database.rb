class IspDatabase < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'
end
  
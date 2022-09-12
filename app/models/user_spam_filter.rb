class UserSpamFilter < ApplicationRecord
  belongs_to :user_domain

  scope :white_lists, -> { where(wb: 'W') }
  scope :black_lists, -> { where(wb: 'B') }
  scope :by_wb_scope, -> (wb){ where(wb: wb) }

end

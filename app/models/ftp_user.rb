# frozen_string_literal: true

class FtpUser < ApplicationRecord
  enum active: { y: 'Yes', n: 'No' }
end

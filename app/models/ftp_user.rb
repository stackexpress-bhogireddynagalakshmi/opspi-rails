class FtpUser < ApplicationRecord
  enum active: { y: 'Yes', n: 'No' }
end

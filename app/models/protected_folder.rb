class ProtectedFolder < ApplicationRecord
  enum active: { y: 'Yes', n: 'No' }
end

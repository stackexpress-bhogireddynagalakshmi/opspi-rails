class Website < ApplicationRecord
  enum active: { y: 'Yes', n: 'No' }
end

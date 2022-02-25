# frozen_string_literal: true

class Website < ApplicationRecord
  enum active: { y: 'Yes', n: 'No' }
end

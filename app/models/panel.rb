class Panel < ApplicationRecord
  belongs_to :panel_type

  def abbr
    "Panel id: #{id}"
  end
end

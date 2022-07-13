class ActivePanel < ApplicationRecord
 
 def self.panel_configs_json
    ActivePanel.all.pluck(:service,:panel_id).to_h
 end

end

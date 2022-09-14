# frozen_string_literal: true

module SolidCp
  # SolidCp Configuration Provder class
  class ErrorHelper
  
    def self.log_solid_cp_error(response, current_method)
      code  = response.body["#{current_method}_response".to_sym]["#{current_method}_result".to_sym].to_i
      error = SolidCp::ErrorCodes.get_by_code(code)
      
      "Error Code: #{code}, Message: #{error[:msg]}"
    end
  end
end

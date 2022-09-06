# frozen_string_literal: true

module Spree
  module Gateway::AuthorizeNetCimDecorator
   
    def custom_name
      "Authorize.net"
    end
    
  end
end

::Spree::Gateway::AuthorizeNetCim.extend Spree::Gateway::AuthorizeNetCimDecorator if ::Spree::Gateway::AuthorizeNetCim.included_modules.exclude?(Spree::Gateway::AuthorizeNetCimDecorator)



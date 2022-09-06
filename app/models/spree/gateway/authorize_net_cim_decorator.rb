# frozen_string_literal: true

module Spree
  module Gateway::AuthorizeNetCimDecorator
   
    def custom_name
      I18n.t("spree.authorize_dot_net")
    end
    
  end
end

::Spree::Gateway::AuthorizeNetCim.extend Spree::Gateway::AuthorizeNetCimDecorator if ::Spree::Gateway::AuthorizeNetCim.included_modules.exclude?(Spree::Gateway::AuthorizeNetCimDecorator)



# frozen_string_literal: true

module Spree
  module Gateway::PayPalExpressDecorator
   
    def custom_name
      "PayPal"
    end

  end
end

::Spree::Gateway::PayPalExpress.extend Spree::Gateway::PayPalExpressDecorator if ::Spree::Gateway::PayPalExpress.included_modules.exclude?(Spree::Gateway::PayPalExpressDecorator)

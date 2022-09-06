# frozen_string_literal: true

module Spree
  module Gateway::StripeGatewayDecorator
   
    def custom_name
      I18n.t("spree.stripe_gateway")
    end

  end
end

::Spree::Gateway::StripeGateway.extend Spree::Gateway::StripeGatewayDecorator if ::Spree::Gateway::StripeGateway.included_modules.exclude?(Spree::Gateway::StripeGatewayDecorator)

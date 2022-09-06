# frozen_string_literal: true

module Spree
  module PaymentMethod::CheckDecorator
   
    def custom_name
      "Check"
    end

  end
end

::Spree::PaymentMethod::Check.extend Spree::PaymentMethod::CheckDecorator if ::Spree::PaymentMethod::Check.included_modules.exclude?(Spree::PaymentMethod::CheckDecorator)

# frozen_string_literal: true

module Spree
  module CountryDecorator
    def country_name_dialing_code
      code = IsoCountryCodes.find(iso)
      "#{iso_name} (#{code.calling})"
    end
  end
end

::Spree::Country.prepend Spree::CountryDecorator if ::Spree::Country.included_modules.exclude?(Spree::CountryDecorator)

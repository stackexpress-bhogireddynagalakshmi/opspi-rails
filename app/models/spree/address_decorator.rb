# frozen_string_literal: true

module Spree
  module AddressDecorator
    Spree::Address::ADDRESS_FIELDS = %w[firstname lastname company country phone address1 address2 state city
                                        zipcode].freeze

    def self.prepended(base)
      base.after_commit :set_first_and_last_name, on: [:update]
      base.after_commit :set_country_code, on: %i[update create]
    end

    def set_first_and_last_name
      return unless user.present?
      return if user.first_name.present? && user.last_name.present?

      user.first_name =  firstname
      user.last_name  =  lastname
      user.save
    end

    def set_country_code
      return unless country.present?

      code = IsoCountryCodes.find(country.iso)
      update_column(:country_code, code.calling)
    end
  end
end

::Spree::Address.prepend Spree::AddressDecorator if ::Spree::Address.included_modules.exclude?(Spree::AddressDecorator)

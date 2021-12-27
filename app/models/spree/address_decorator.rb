module Spree
	module AddressDecorator
    Spree::Address::ADDRESS_FIELDS = %w(firstname lastname company phone address1 address2 country state city zipcode).freeze

    def self.prepended(base)
      base.after_commit :set_first_and_last_name, on: [:update]
      base.after_commit :set_country_code, on: [:update, :create]
    end

    def set_first_and_last_name
      return unless self.user.present?
      return if self.user.first_name.present? && self.user.last_name.present?

      self.user.first_name =  self.firstname
      self.user.last_name  =  self.lastname
      self.user.save
    end

    def set_country_code
      return unless country.present?

      code = IsoCountryCodes.find(country.iso)
      update_column(:country_code,code.calling)
    end
   
	end
end

::Spree::Address.prepend Spree::AddressDecorator if ::Spree::Address.included_modules.exclude?(Spree::AddressDecorator)


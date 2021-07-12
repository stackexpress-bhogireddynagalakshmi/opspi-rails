module Spree
	module AddressDecorator
    Spree::Address::ADDRESS_FIELDS = %w(firstname lastname company phone address1 address2 country state city zipcode).freeze

    def self.prepended(base)
      base.after_commit :set_first_and_last_name, on: [:create]
    end

    def set_first_and_last_name
      self.firstname = self.user&.first_name
      self.lastname = self.user&.last_name
      self.save
    end

	end
end

::Spree::Address.prepend Spree::AddressDecorator if ::Spree::Address.included_modules.exclude?(Spree::AddressDecorator)



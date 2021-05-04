module Spree
	module AddressDecorator
		Spree::Address::ADDRESS_FIELDS = %w(firstname lastname company phone address1 address2 country state city zipcode).freeze
	end
end


::Spree::Address.prepend Spree::AddressDecorator if ::Spree::Address.included_modules.exclude?(Spree::AddressDecorator)



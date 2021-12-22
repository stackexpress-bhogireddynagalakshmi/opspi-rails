module Spree
	module AddressDecorator
    Spree::Address::ADDRESS_FIELDS = %w(firstname lastname company country_code phone address1 address2 country state city zipcode).freeze

    def self.prepended(base)
      base.after_commit :set_first_and_last_name, on: [:update]
    end

    def set_first_and_last_name
      #return unless user_id_changed?
      return unless self.user.present?
      return if self.user.first_name.present? && self.user.last_name.present?

       self.user.first_name =  self.firstname
       self.user.last_name  =  self.lastname
       self.user.save
    end
   
	end
end

::Spree::Address.prepend Spree::AddressDecorator if ::Spree::Address.included_modules.exclude?(Spree::AddressDecorator)
Spree::PermittedAttributes.address_attributes << :country_code


module Spree
	module AddressDecorator
    Spree::Address::ADDRESS_FIELDS = %w(firstname lastname company phone address1 address2 country state city zipcode).freeze

    def self.prepended(base)
      base.validate :validate_phone_number

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
    def validate_phone_number
      return if phone.blank?
      unless phone.match(/\+(9[976]\d|8[987530]\d|6[987]\d|5[90]\d|42\d|3[875]\d|
2[98654321]\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|
4[987654310]|3[9643210]|2[70]|7|1|49|2[987654321])\d{10,14}$/)
         self.errors.add(:phone, "Number or Country Code In Valid")
      end
    end

	end
end

::Spree::Address.prepend Spree::AddressDecorator if ::Spree::Address.included_modules.exclude?(Spree::AddressDecorator)



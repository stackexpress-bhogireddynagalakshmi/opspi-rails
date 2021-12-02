module DnsManager  
  module ResellerClub
    class ContactCreator < ApplicationService
      attr_reader :user

      def initialize(user,opts={})
        @user   = user
      end

      def call
        return nil if user.reseller_club_contact_id.present?
        return nil if user.reseller_club_customer_id.blank?

        response = ::ResellerClub::Contact.add(customer_params)

        if response[:success]
          user.update_column(:reseller_club_contact_id,response[:response]["code"])
        end

        response
      end


      private

      def customer_params
        address = user.addresses.first

        {
          "name"            =>  user.first_name,
          "email"          =>  user.email,
          "company"         =>  user.company_name,
          "address-line-1"  =>  address&.address1,
          "city"            =>  address&.city,
          "state"           =>  address&.state&.name,
          "country"         =>  address&.country&.iso,
          "zipcode"         =>  address&.zipcode,
          "phone-cc"        =>   "1",
          "phone"           =>  address&.phone,
          "customer-id"     =>  user.reseller_club_customer_id.to_s,
          "lang-pref"       =>  "en",
          "type"            =>  "Contact" 
        }
      end

    end
  end
end
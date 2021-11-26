module DnsManager  
  module ResellerClub
    class DomainRegistrar < ApplicationService
      attr_reader :user,:domain,:validity

      def initialize(user,opts={})
        @user    = user
        @domain  = opts[:domain]
        @validity = opts[:validity]
      end

      def call
        response =  ::ResellerClub::Domain.register(domain_registration_params)
        response[:success]
      end

    
      private
    
      def  domain_registration_params
        { 
          "domain-name"       => domain,
          "years"             => validity,
          "ns"                => name_server,
          "customer_id"       => user.reseller_club_customer_id,
          "reg-contact-id"    => user.reseller_club_contact_id,
          "admin-contact-id"  => user.reseller_club_contact_id,
          "tech-contact-id"   => user.reseller_club_contact_id,
          "billing-contact-id" => user.reseller_club_contact_id,
          "invoice-option"    => "NoInvoice",
          "protect-privacy"   => protect_privacy,
          "attr-name1"        => "idnLanguageCode",
          "attr-value1"       => "aze"
        }
      end

      def name_server
        []
      end

    end
  end
end
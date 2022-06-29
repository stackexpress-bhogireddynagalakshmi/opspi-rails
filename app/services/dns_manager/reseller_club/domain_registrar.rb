module DnsManager  
  module ResellerClub
    class DomainRegistrar < ApplicationService
      attr_reader :user,:domain,:validity,:protect_privacy,:line_item

      def initialize(user,opts={})
        @user    = user
        @domain  = opts[:domain]
        @validity = opts[:validity]
        @protect_privacy = opts[:protect_privacy]
        @line_item  = opts[:line_item]
      end

      def call
        result = ::ResellerClub::Domain.register(domain_registration_params)
        if result[:success] == true
          line_item.domain_successfully_registered = true
          line_item.domain_registered_at = Time.zone.now
        end
        line_item.api_response = result[:response]
        line_item.save
        
        result
      end

      private    
      def  domain_registration_params
        { 
          "domain-name"       => domain,
          "years"             => validity,
          "ns"                => name_server,
          "customer-id"       => user.reseller_club_customer_id,
          "reg-contact-id"    => user.reseller_club_contact_id,
          "admin-contact-id"  => user.reseller_club_contact_id,
          "tech-contact-id"   => user.reseller_club_contact_id,
          "billing-contact-id" => user.reseller_club_contact_id,
          "invoice-option"    => "NoInvoice",
          "protect-privacy"   => protect_privacy,
          "attr-name1"        => "idnLanguageCode",
          "attr-value1"       => "aze",
          "email"             => @user.email
        }
      end

      def name_server
       [ENV['DNS_SERVER_NS1'], ENV['DNS_SERVER_NS2']]
      end

    end
  end
end
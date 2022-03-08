# frozen_string_literal: true

module SolidCp
  module Dns
    class Domain < Base
      attr_reader :user

      def initialize(user)
        @user = user
      end

      client wsdl: SOAP_SERVER_WSDL, endpoint: SOAP_SERVER_WSDL, log: SolidCp::Config.log
      global :read_timeout, SolidCp::Config.timeout
      global :open_timeout, SolidCp::Config.timeout
      global :basic_auth, SolidCp::Config.username, SolidCp::Config.password

      operations :get_domain_dns_records,
                 :get_domains,
                 :get_domains_by_domain_id,
                 :get_my_domains,
                 :get_reseller_domains,
                 :get_domains_paged,
                 :get_domain,
                 :add_domain,
                 :add_domain_with_provisioning,
                 :update_domain,
                 :delete_domain,
                 :detach_domain,
                 :enable_domain_dns,
                 :disable_domain_dns,
                 :create_domain_preview_domain,
                 :delete_domain_preview_domain

    
      # <packageId>int</packageId>
      def get_domains
        response = super(message: { package_id: user.packages.first.try(:solid_cp_package_id), user_id: user.solid_cp_id })
      end
      alias :all :get_domains

   
      # @params
      # <DomainId>int</DomainId>
      # <PackageId>int</PackageId>
      # <ZoneItemId>int</ZoneItemId>
      # <DomainItemId>int</DomainItemId>
      # <DomainName>string</DomainName>
      # <HostingAllowed>boolean</HostingAllowed>
      # <WebSiteId>int</WebSiteId>
      # <MailDomainId>int</MailDomainId>
      # <WebSiteName>string</WebSiteName>
      # <MailDomainName>string</MailDomainName>
      # <ZoneName>string</ZoneName>
      # <IsSubDomain>boolean</IsSubDomain>
      # <IsPreviewDomain>boolean</IsPreviewDomain>
      # <IsDomainPointer>boolean</IsDomainPointer>
      # <PreviewDomainId>int</PreviewDomainId>
      # <PreviewDomainName>string</PreviewDomainName>
      # <CreationDate>dateTime</CreationDate>
      # <ExpirationDate>dateTime</ExpirationDate>
      # <LastUpdateDate>dateTime</LastUpdateDate>
      # <RegistrarName>string</RegistrarName>

      def  add_domain(params={})
        response = super(message: {
          domain: {
          "PackageId" => user.packages.first.try(:solid_cp_package_id),
          "HostingAllowed" => true,
          "DomainName" => params[:domain_name],
          "IsSubDomain" => false,
          "IsPreviewDomain" => false,
          "IsDomainPointer" => true,
          "UserId" => user.solid_cp_id
        }}
        )
        if response.success? && response.body[:add_domain_response][:add_domain_result].to_i.positive? 
          domian_id = response.body[:add_domain_response][:add_domain_result].to_i

          update_dns_settings(domian_id, params[:enable_dns])
        
          { success: true, message: 'Domain created successfully', response: response }
        else
          { success: false, message: 'Something went wrong. Please try again.', response: response }
        end
      end
      

      # @params
      # <DomainId>int</DomainId>
      # <PackageId>int</PackageId>
      # <ZoneItemId>int</ZoneItemId>
      # <DomainItemId>int</DomainItemId>
      # <DomainName>string</DomainName>
      # <HostingAllowed>boolean</HostingAllowed>
      # <WebSiteId>int</WebSiteId>
      # <MailDomainId>int</MailDomainId>
      # <WebSiteName>string</WebSiteName>
      # <MailDomainName>string</MailDomainName>
      # <ZoneName>string</ZoneName>
      # <IsSubDomain>boolean</IsSubDomain>
      # <IsPreviewDomain>boolean</IsPreviewDomain>
      # <IsDomainPointer>boolean</IsDomainPointer>
      # <PreviewDomainId>int</PreviewDomainId>
      # <PreviewDomainName>string</PreviewDomainName>
      # <CreationDate>dateTime</CreationDate>
      # <ExpirationDate>dateTime</ExpirationDate>
      # <LastUpdateDate>dateTime</LastUpdateDate>
      # <RegistrarName>string</RegistrarName>

      def update_domain(id, params)
          response = super(message: {
          domain: {
          "DomainId"  => id,
          "PackageId" => user.packages.first.try(:solid_cp_package_id),
          "HostingAllowed" => true,
          "DomainName" => params[:domain_name],
          "IsSubDomain" => false,
          "IsPreviewDomain" => false,
          "IsDomainPointer" => true
        }}
        )

        if response.success?            
          update_dns_settings(id, params[:enable_dns])
          { success: true, message: 'Domain updated successfully', response: response }
        else
          { success: false, message: 'Something went wrong. Please try again.', response: response }
        end

      end
      alias :update :update_domain

      # @params
      # <domainId>int</domainId>
      def get_domain(id)
        response = super(message: { domain_id: id })
      end
      alias :find :get_domain

      # @params
      # <domainId>int</domainId>
      def delete_domain(id)
         response = super(message: { domain_id: id })

         if response.success? 
          { success: true, message: 'Domain deleted successfully', response: response }
        else
          { success: false, message: 'Something went wrong. Please try again.', response: response }
        end
      end
      alias :destroy :delete_domain

      # @params
      # <domainId>int</domainId>
      def enable_domain_dns(id)
        response = super(message: { domain_id: id })
      end

      # @params
      # <domainId>int</domainId>
      def disable_domain_dns(id)
        response = super(message: { domain_id: id })
      end


      # @params
      #  <packageId>int</packageId>
      # <domainName>string</domainName>
      # <domainType>Domain or SubDomain or ProviderSubDomain or DomainPointer</domainType>
      # <createWebSite>boolean</createWebSite>
      # <pointWebSiteId>int</pointWebSiteId>
      # <pointMailDomainId>int</pointMailDomainId>
      # <createDnsZone>boolean</createDnsZone>
      # <createPreviewDomain>boolean</createPreviewDomain>
      # <allowSubDomains>boolean</allowSubDomains>
      # <hostName>string</hostName> 

      def add_domain_with_provisioning(params={})

        hash_params = {
          "packageId" => user.packages.first.try(:solid_cp_package_id),
          "domainName" => params[:domain_name],
          "domainType" => 'Domain',
          "createWebSite" => true,
          "createDnsZone" => false,
          "createPreviewDomain" => false,
          "allowSubDomains" => true,
          "hostName"=> "",
         }

         response = super(message: hash_params )

        if response.success? && response.body[:add_domain_with_provisioning_response][:add_domain_with_provisioning_result].to_i.positive? 
          { success: true, message: 'Domain created successfully', response: response }
        else
          { success: false, message: 'Something went wrong. Please try again.', response: response }
        end
      end
      alias :create :add_domain_with_provisioning 


      private
      def update_dns_settings(domain_id, enable_dns)
        if enable_dns == true || enable_dns == 'true'
          enable_domain_dns(domain_id)
        else
          disable_domain_dns(domain_id)
        end
      end

    end
  end
end

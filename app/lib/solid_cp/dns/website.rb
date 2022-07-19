# frozen_string_literal: true

module SolidCp
    module Dns
      class Website < Base
        attr_reader :user
  
        def initialize(user)
          @user = user
        end
  
        client wsdl: SOAP_WEB_SERVER_WSDL, endpoint: SOAP_WEB_SERVER_WSDL, log: SolidCp::Config.log
        global :read_timeout, SolidCp::Config.timeout
        global :open_timeout, SolidCp::Config.timeout
        global :basic_auth, SolidCp::Config.username, SolidCp::Config.password
  
        operations :delete_web_site,
                   :get_web_sites,
                   :install_certificate,
                   :check_ssl_for_domain,
                   :check_ssl_for_website,
                   :le_install_certificate


        # <packageId>int</packageId>
        def get_web_sites
          response = super(message: { package_id: user.packages.first.try(:solid_cp_package_id) })
        end
        alias :all :get_web_sites
      
        # @params
        # <siteItemId>int</siteItemId>
        # <deleteWebsiteDirectory>boolean</deleteWebsiteDirectory>
        def delete_web_site(params)
           response = super(message: { site_item_id: params[:web_site_id],delete_website_directory: true })
  
           if response.success? 
            domain_response = Domain.new(user).destroy(params[:id])
            
            if domain_response[:success] == true 
              { success: true, message: 'Website deleted successfully', response: response }
            else
              { success: false, message: 'Something went wrong. Please try again.', response: response }
            end
           else
            { success: false, message: 'Something went wrong. Please try again.', response: response }
           end
        end
        alias :destroy :delete_web_site

         # <siteID>int</siteID>
         # <renewal>boolean</renewal>
         def check_ssl_for_website(params)
          response = super(message: { site_id: params[:web_site_id] })
         end

        #  <siteItemId>int</siteItemId>
        #  <email>string</email>
         def le_install_certificate(params)
          response = super(message: { site_item_id: params[:web_site_id], email: user.email })
         end

      #   <certificate>
      #   <id>int</id>
      #   <FriendlyName>string</FriendlyName>
      #   <Hostname>string</Hostname>
      #   <DistinguishedName>string</DistinguishedName>
      #   <CSR>string</CSR>
      #   <CSRLength>int</CSRLength>
      #   <SiteID>int</SiteID>
      #   <UserID>int</UserID>
      #   <Installed>boolean</Installed>
      #   <PrivateKey>string</PrivateKey>
      #   <Certificate>string</Certificate>
      #   <Hash>base64Binary</Hash>
      #   <Organisation>string</Organisation>
      #   <OrganisationUnit>string</OrganisationUnit>
      #   <City>string</City>
      #   <State>string</State>
      #   <Country>string</Country>
      #   <ValidFrom>dateTime</ValidFrom>
      #   <ExpiryDate>dateTime</ExpiryDate>
      #   <SerialNumber>string</SerialNumber>
      #   <Pfx>base64Binary</Pfx>
      #   <Password>string</Password>
      #   <Success>boolean</Success>
      #   <IsRenewal>boolean</IsRenewal>
      #   <PreviousId>int</PreviousId>
      # </certificate>
      # <siteItemId>int</siteItemId>
         def install_certificate(params)
          response = super(message: {
            item: {
              "SiteID" => params[:web_site_id],
              "Hostname"=> params[:website][:domain],
              "UserID" => user.solid_cp_id,
              "PackageId" => user.packages.first.try(:solid_cp_package_id)
            },
            site_item_id: params[:web_site_id]
          }
          )
          code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
          error = SolidCp::ErrorCodes.get_by_code(code)
          # if response.success? && code.positive?
          #   { success: true, message: I18n.t(:'windows.database.create'), response: response }
          # else
          #   { success: false, message: I18n.t(:panel_error, msg: error[:msg]), response: response }
          # end
          # rescue StandardError => e
          #   { success: false, message: I18n.t(:panel_error, msg: e.message), response: response }
          end
        
      end
    end
  end
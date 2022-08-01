# frozen_string_literal: true

module SolidCp
    module Dns
      class Website < Base
        attr_reader :user
  
        def initialize(user)
          @user = user

          set_configurations(user, SOAP_WEB_SERVER_WSDL)
        end
  
      
        operations :delete_web_site,
                   :get_web_sites,
                   :install_certificate,
                   :check_ssl_for_domain,
                   :check_ssl_for_website,
                   :check_certificate,
                   :get_certificates_for_site,
                   :le_install_certificate,
                   :delete_web_site_pointer,
                   :get_web_site,
                   :get_site_cert,
                   :get_site_state,
                   :get_web_site_pointers,
                   :delete_certificate,
                   :import_certificate

        # <packageId>int</packageId>
        def get_web_sites
          response = super(message: { package_id: user.packages.first.try(:solid_cp_package_id) })
        end
        alias :all :get_web_sites
      
        #<siteItemId>int</siteItemId>
        def get_web_site(params)
          response = super(message: { site_item_id: params[:web_site_id] })
        end

        #<siteItemId>int</siteItemId>
        def get_web_site_pointers(params)
          response = super(message: { site_item_id: params[:web_site_id] })
          response.body[:get_web_site_pointers_response][:get_web_site_pointers_result][:domain_info] rescue []
        end

        #<siteId>int</siteId>
        def get_certificates_for_site(params)  ## get cert
          response = super(message: { site_id: params[:web_site_id] })
        end

        #<siteItemId>int</siteItemId>
        #<domainId>int</domainId>
        def delete_web_site_pointer(params)
          response = super(message: { site_item_id: params[:web_site_id], domain_id: params[:website][:web_domain_id] })
        end

        # @params
        # <siteItemId>int</siteItemId>
        # <deleteWebsiteDirectory>boolean</deleteWebsiteDirectory>
        def delete_web_site(params)
           response = super(message: { site_item_id: params[:web_site_id],delete_website_directory: true })
  
           if response.success? 
            domain_response = Domain.new(user).destroy(params[:web_domain_id])
            
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


        #  <siteItemId>int</siteItemId>
        #  <email>string</email>
         def le_install_certificate(params)
          response = super(message: { site_item_id: params[:web_site_id], email: user.email })
          if response.success? && response.body[:le_install_certificate_response][:le_install_certificate_result][:is_success] == true 
            { success: true, message: 'Certificate Installed successfully', response: response }
          else
            { success: false, message: 'Something went wrong. Please try again.', response: response }
          end
         end

        def delete_certificate(params)
          response = super(message: {
            site_id: params[:web_site_id],
            certificate: {
              "id" => params[:website][:id],
              "SiteID" => params[:web_site_id],
              "Hostname"=> params[:website][:domain],
              "UserID" => user.solid_cp_id,
              "PackageId" => user.packages.first.try(:solid_cp_package_id)
            }
          }
          )
          if response.success?
            { success: true, message: 'SSL deleted successfully', response: response }
          else
            { success: false, message: 'Something went wrong. Please try again.', response: response }
          end
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
            certificate: {
              "SiteID" => params[:web_site_id],
              "Hostname"=> params[:website][:domain],
              "UserID" => user.solid_cp_id,
              "PackageId" => user.packages.first.try(:solid_cp_package_id),
              "ValidFrom" => DateTime.now
            },
            site_item_id: params[:web_site_id]
          }
          )
          code  = response.body["#{__method__}_response".to_sym]["#{__method__}_result".to_sym].to_i
          error = SolidCp::ErrorCodes.get_by_code(code)
          if response.success? && code.positive?
            { success: true, message: I18n.t(:'windows.database.create'), response: response }
          else
            { success: false, message: I18n.t(:panel_error, msg: error[:msg]), response: response }
          end
          rescue StandardError => e
            { success: false, message: I18n.t(:panel_error, msg: e.message), response: response }
          end
        
      end
    end
  end
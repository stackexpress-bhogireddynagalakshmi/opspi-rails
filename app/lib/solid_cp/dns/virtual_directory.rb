# frozen_string_literal: true

module SolidCp
  module Dns
    class VirtualDirectory < Base
      attr_reader :user

      def initialize(user)
        @user = user
      end

      client wsdl: SOAP_WEB_SERVER_WSDL, endpoint: SOAP_WEB_SERVER_WSDL, log: SolidCp::Config.log
      global :read_timeout, SolidCp::Config.timeout
      global :open_timeout, SolidCp::Config.timeout
      global :basic_auth, SolidCp::Config.username, SolidCp::Config.password

      operations :add_virtual_directory,
                 :get_virtual_directory,
                 :update_virtual_directory,
                 :delete_virtual_directory,
                 :add_app_virtual_directory,
                 :get_app_virtual_directory,
                 :update_app_virtual_directory,
                 :delete_app_virtual_directory






      def get_virtual_directory

      end
      alias :find :get_virtual_directory


      #   <UpdateVirtualDirectory xmlns="http://smbsaas/solidcp/enterpriseserver">
      #   <siteItemId>int</siteItemId>
      #   <vdir>
      #     <SiteId>string</SiteId>
      #     <AnonymousUsername>string</AnonymousUsername>
      #     <AnonymousUserPassword>string</AnonymousUserPassword>
      #     <ContentPath>string</ContentPath>
      #     <EnableParentPaths>boolean</EnableParentPaths>
      #     <EnableWritePermissions>boolean</EnableWritePermissions>
      #     <EnableDirectoryBrowsing>boolean</EnableDirectoryBrowsing>
      #     <EnableAnonymousAccess>boolean</EnableAnonymousAccess>
      #     <EnableWindowsAuthentication>boolean</EnableWindowsAuthentication>
      #     <EnableBasicAuthentication>boolean</EnableBasicAuthentication>
      #     <EnableDynamicCompression>boolean</EnableDynamicCompression>
      #     <EnableStaticCompression>boolean</EnableStaticCompression>
      #     <ParentSiteName>string</ParentSiteName>
      #     <IIs7>boolean</IIs7>
      #   </vdir>
      # </UpdateVirtualDirectory>

      def update_app_virtual_directory(id, params)
        response = super(message: {
          "siteItemId" => 1,

          vdir: {
            "SiteId"  => id,
            "EnableParentPaths" => user.packages.first.try(:solid_cp_package_id),
            "EnableWritePermissions" => true,
            "EnableDirectoryBrowsing" => params[:domain_name],
            "EnableAnonymousAccess" => false,
            "EnableWindowsAuthentication" => false,
            "EnableWindowsAuthentication" => false,
            "EnableBasicAuthentication" => false,
            "EnableDynamicCompression" => false,
            "EnableStaticCompression" => false,
            "ParentSiteName" => "",
            "IIs7" => false,
        }}
        )

        if response.success?            
          update_dns_settings(id, params[:enable_dns])
          { success: true, message: 'Website updated successfully', response: response }
        else
          { success: false, message: 'Something went wrong. Please try again.', response: response }
        end

      end
      alias :update :update_app_virtual_directory



    end
  end
end

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
                   :get_web_sites


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
  
  
      end
    end
  end
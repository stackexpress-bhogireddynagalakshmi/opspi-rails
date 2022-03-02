# frozen_string_literal: true

module SolidCp
  class Base
    extend Savon::Model
    attr_reader :soap_wsdl

    SOAP_USER_WSDL = "#{SolidCp::Config.base_url}esUsers.asmx?wsdl".freeze
    SOAP_PLAN_WSDL = "#{SolidCp::Config.base_url}esPackages.asmx?wsdl".freeze
    SOAP_SERVER_WSDL = "#{SolidCp::Config.base_url}esServers.asmx?wsdl".freeze
    SOAP_WEB_SERVER_WSDL = "#{SolidCp::Config.base_url}esWebServers.asmx?wsdl".freeze

  end
end

# frozen_string_literal: true

module SolidCp
  class Base
    extend Savon::Model
    attr_reader :soap_wsdl

    SOAP_USER_WSDL        = "esUsers.asmx?wsdl"
    SOAP_PLAN_WSDL        = "esPackages.asmx?wsdl"
    SOAP_SERVER_WSDL      = "esServers.asmx?wsdl"
    SOAP_WEB_SERVER_WSDL  = "esWebServers.asmx?wsdl"
    SOAP_FTP_WSDL         = "esFtpServers.asmx?wsdl"
    SOAP_SQL_WSDL         = "esDatabaseServers.asmx?wsdl"

    def initialize(user)
      @user = user
    end

    def set_configurations(user, wsdl)
      base_url = SolidCp::Config.api_url(user.panel_config[SolidCp::Config::SERVER_TYPE])
      wsdl_url = "#{base_url}#{wsdl}"
      self.class.client wsdl: wsdl_url, endpoint: wsdl_url, log: SolidCp::Config.log
      self.class.global :read_timeout, SolidCp::Config.timeout
      self.class.global :open_timeout, SolidCp::Config.timeout
      self.class.global :basic_auth, SolidCp::Config.api_username(user), SolidCp::Config.api_password(user)
    end

    def self.set_configurations(user, wsdl)
      base_url = SolidCp::Config.api_url(user.panel_config[SolidCp::Config::SERVER_TYPE])
      wsdl_url = "#{base_url}#{wsdl}"
      client wsdl: wsdl_url, endpoint: wsdl_url, log: SolidCp::Config.log
      global :read_timeout, SolidCp::Config.timeout
      global :open_timeout, SolidCp::Config.timeout
      global :basic_auth, SolidCp::Config.api_username(user), SolidCp::Config.api_password(user)
    end
  end
end

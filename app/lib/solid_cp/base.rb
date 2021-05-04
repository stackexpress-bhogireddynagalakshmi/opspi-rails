module SolidCp
	class Base
		extend Savon::Model
		attr_reader :soap_wsdl
		SOAP_USER_WSDL = SolidCp::Config.base_url+"esUsers.asmx?wsdl"
		SOAP_PLAN_WSDL = SolidCp::Config.base_url+"esPackages.asmx?wsdl"
	end
end

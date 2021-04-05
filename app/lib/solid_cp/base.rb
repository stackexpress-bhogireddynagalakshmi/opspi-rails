module SolidCp
	class Base
		extend Savon::Model
		attr_reader :soap_wsdl
		SOAP_USER_WSDL = SolidCp::Config.base_url+"esUsers.asmx?wsdl"
		SOAP_PLAN_WSDL = SolidCp::Config.base_url+"esPackages.asmx?wsdl"
	end
end

# class Hash
#   def to_o
#     JSON.parse to_json, object_class: OpenStruct
#   end
# end
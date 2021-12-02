require "typhoeus"
require "open-uri"
require "json"

module ResellerClub
  module MethodBuilder

    def construct_url(params, method)
      params.delete_if {|k,v| v == ""}
      url = self::BASE_URL + method + "?"
      url += URI.encode_www_form(params)
      url
    end

    def generate_method_name_from_url(url)
      url.split(".")[0].gsub("/", "_").gsub("-","_")
    end

    def build_method(data)
      construct_url_bind = method(:construct_url)
  
      if data["method_name"].nil?
        data["method_name"] = generate_method_name_from_url(data["url"])
      end
      define_method data["method_name"] do |params={}|
        mock = false
        if params.kind_of? Hash
          mock = params.delete("test_mock")
          mock ||= params.delete(:test_mock)
        end
        
        if data["values"].nil?
          data["values"] = {}
        elsif data["values"].keys.count == 1 and (data["values"].values)[0] == ""
          if params.kind_of? Hash
            data["values"].merge!(params)
          elsif params.kind_of? String
            data["values"][(data["values"].keys)[0]] = params
          end
        else
          data["values"].merge!(params)
        end

        data["values"]['auth-userid']   = ENV['RESELLER_CLUB_ACCOUNT_ID']
        data["values"]["api-key"]       =  ENV['RESELLER_CLUB_API_KEY']
    

        if data["validate"].call(data["values"])
          url = construct_url_bind.call(data["values"], data["url"])
          return url if mock
  
          ResellerClub::RequestWrapper.new(url,data).call
        else
          raise "Validation failed."
        end
      end
    end

  end
end
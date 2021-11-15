module ResellerClub
  class UrlBuilder
    attr_reader :data

    def initialize(data,opts={})
      @data = data
      set_auth_keys
    end

    def call
      byebug
      # construct_url_bind = method(:construct_url)

      # construct_url_bind.call(data["values"], data["url"])
      construct_url(data["values"],data["url"])
    end 

    def construct_url(params, method)
      params.delete_if {|k,v| v == ""}
      url = self::BASE_URL + method + "?"
      params.each do |k,v|
        if v.kind_of?(Array)
          v.each { |elem| url = url + k.gsub("_","-") + "=" + elem + "&"}
        else
          url = url + k.gsub("_","-") + "=" + v + "&"
        end
      end
      url = url[0..-2] if url[-1] == "&"
       
      url
    end

     def set_auth_keys
      @data["values"]['auth-userid']   = "18749"
      @data["values"]["api-key"] =  'CGWfMhdcGziR5XGa37aE2YDbTwTiNMG1'
    end


  end
end
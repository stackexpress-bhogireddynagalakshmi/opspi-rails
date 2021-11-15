require "typhoeus"
module ResellerClub
  class TyphoeusClient
    attr_reader :url,:data
   
    def initialize(url,params,opts= {})
      @data = params 
      @url  = url
    end

    def call
      true_false_or_text_bind = method(:true_false_or_text)


      if data["silent"]
        Typhoeus::Request.send data["http_method"], url
      else

        response = Typhoeus::Request.send data["http_method"], url
        case response.code
        when 200
          return JSON.parse(true_false_or_text_bind.call(response.body))
        when 500
          error = JSON.parse(true_false_or_text_bind.call(response.body))
          raise error["message"]
        when 404
          raise "Action not Found"
        else
 
          error = JSON.parse(true_false_or_text_bind.call(response.body))
          raise error["message"]
        end
      end
    end

    private

    def true_false_or_text(str)
      if str == "true"
        return {"response" => true}.to_json
      elsif str == "false"
        return {"response" => false}.to_json
      elsif str.to_i.to_s == str
        return {"code" => str}.to_json
      else
        begin
          JSON.parse(str)
        rescue
          return {"response" => str}.to_json
        end
        return str
      end
    end
  end
end
require "typhoeus"
module ResellerClub
  class TyphoeusClient
    attr_reader :url,:data,:success

   
    def initialize(url,params,opts= {})
      @data = params 
      @url  = url
      @success = false
    end

    def call
      true_false_or_text_bind = method(:true_false_or_text)

      if data["silent"]
        Typhoeus::Request.send data["http_method"], url
      else

        response = Typhoeus::Request.send data["http_method"], url

        parsed_response = JSON.parse(true_false_or_text_bind.call(response.body))

        Rails.logger.info { parsed_response }

        success = true if response.code == 200

        return { success: success, response: parsed_response }


        # byebug
        # case response.code
        # when 200
        #   success = true
        #   return JSON.parse(true_false_or_text_bind.call(response.body))
        # when 500
        #   error = JSON.parse(true_false_or_text_bind.call(response.body))
        #   raise  Exception.new  error["response"]
        # when 404
        #   raise  Exception.new  "Action not Found #{error["response"]}"
        # else
        #   error = JSON.parse(true_false_or_text_bind.call(response.body))
          
        #   return JSON.parse(true_false_or_text_bind.call(response.body))
        # end
      end
    end

    def success?
      success
    end

    def failure?
      !success
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
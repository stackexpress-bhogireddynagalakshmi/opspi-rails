module ResellerClub
  class RequestWrapper
    attr_reader :url, :data 

    def initialize(url,data,opts={})
      @url  = url
      @data = data
    end

    def call
      ResellerClub::TyphoeusClient.new(url,data).call
    end

  end
end
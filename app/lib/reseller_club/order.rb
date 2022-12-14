# frozen_string_literal: true

module ResellerClub
  class Order
    class << self
      extend MethodBuilder

      BASE_URL = "#{ResellerClub::Config.base_url}/orders/".freeze

      [{ "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "suspend.json" },
       { "values" => { "order_id" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                    true
                                                                                  }, "url" => "unsuspend.json" }].each { |p| build_method p }
   end
  end
end

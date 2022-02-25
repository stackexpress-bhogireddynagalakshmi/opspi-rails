# frozen_string_literal: true

module ResellerClub
  class Customer
    class << self
      extend MethodBuilder
      BASE_URL = "#{ResellerClub::Config.base_url}/customers/".freeze

      [{ "values" => { "lang_pref" => "en" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                       true
                                                                                     }, "url" => "v2/signup.json" },
       { "values" => { "lang_pref" => "en" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                       true
                                                                                     }, "url" => "modify.json" },
       { "values" => { "username" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                   true
                                                                                 }, "url" => "details.json" },
       { "values" => { "customer_id" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                      true
                                                                                    }, "url" => "details-by-id.json" },
       { "values" => {}, "http_method" => "get", "validate" => ->(_v) { true }, "url" => "change-password.json" },
       { "values" => { "customer_id" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                      true
                                                                                    }, "url" => "temp-password.json" },
       { "values" => { "no_of_records" => "50", "page_no" => "1" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                                            true
                                                                                                          }, "url" => "search.json" },
       { "values" => { "customer_id" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                       true
                                                                                     }, "url" => "delete.json" },
       { "values" => {}, "http_method" => "get", "validate" => ->(_v) { true }, "url" => "generate-token.json" },
       { "values" => { "token" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                 true
                                                                               }, "url" => "authenticate-token.json" }].each { |p| build_method p }
   end
  end
end

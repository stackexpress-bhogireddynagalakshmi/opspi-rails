# frozen_string_literal: true

module ResellerClub
  class Contact
    class << self
      extend MethodBuilder

      BASE_URL = "#{ResellerClub::Config.base_url}/contacts/".freeze

      [{ "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "add.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "modify.json" },
       { "values" => { "contact_id" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                     true
                                                                                   }, "url" => "details.json" },
       { "values" => {}, "http_method" => "get", "validate" => ->(_v) { true }, "url" => "default.json" },
       { "values" => { "no_of_records" => "50", "page_no" => "1" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                                            true
                                                                                                          }, "url" => "search.json" },
       { "values" => { "contact_id" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                      true
                                                                                    }, "url" => "delete.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "set-details.json" },
       { "values" => { "customer_id" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                      true
                                                                                    }, "url" => "sponsors.json" },
       { "values" => {}, "http_method" => "get", "validate" => ->(_v) { true }, "url" => "coop/add-sponsor.json" },
       { "values" => nil, "http_method" => "get", "validate" => lambda { |_v|
                                                                  true
                                                                }, "url" => "dotca/registrantagreement.json" },
       { "values" => {}, "http_method" => "get", "validate" => lambda { |_v|
                                                                 true
                                                               }, "url" => "validate-registrant.json" }].each { |p| build_method p }
   end
  end
end

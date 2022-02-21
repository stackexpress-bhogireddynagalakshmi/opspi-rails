# frozen_string_literal: true

module ResellerClub
  class Domain
    class << self
      extend MethodBuilder

      BASE_URL = "#{ResellerClub::Config.base_url}/domains/".freeze

      [{ "values" => {}, "http_method" => "get", "validate" => ->(_v) { true }, "url" => "available.json" },
       { "values" => {}, "http_method" => "get", "validate" => ->(_v) { true }, "url" => "idn-available.json" },
       { "values" => {}, "http_method" => "get", "validate" => ->(_v) { true }, "url" => "v5/suggest-names.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "register.json" },
       { "values" => { "domain-name" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                      true
                                                                                    }, "url" => "validate-transfer.json" },
       { "values" => { "domain-name" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                       true
                                                                                     }, "url" => "transfer.json" },

       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "renew.json" },
       { "values" => { "no-of-records" => "10", "page_no" => "1" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                                            true
                                                                                                          }, "url" => "search.json" },
       { "values" => { "customer_id" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                      true
                                                                                    }, "url" => "customer-default-ns.json" },
       { "values" => { "domain_name" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                      true
                                                                                    }, "url" => "orderid.json" },
       { "values" => {}, "http_method" => "get", "validate" => ->(_v) { true }, "url" => "details.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "modify-ns.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "add-cns.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "modify-cns-name.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "modify-cns-ip.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "delete-cns-ip.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "modify-contact.json" },
       { "values" => {}, "http_method" => "post", "validate" => lambda { |_v|
                                                                  true
                                                                }, "url" => "modify-privacy-protection.json" },
       { "values" => {}, "http_method" => "post", "validate" => lambda { |_v|
                                                                  true
                                                                }, "url" => "modify-auth-code.json" },
       { "values" => { "order_id" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                    true
                                                                                  }, "url" => "enable-theft-protection.json" },
       { "values" => { "order_id" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                    true
                                                                                  }, "url" => "disable-theft-protection.json" },
       { "values" => { "order_id" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                   true
                                                                                 }, "url" => "locks.json" },
       { "values" => { "order_id" => "" }, "http_method" => "get", "validate" => lambda { |_v|
                                                                                   true
                                                                                 }, "url" => "tel/cth-details.json" },
       { "values" => {}, "http_method" => "post", "validate" => lambda { |_v|
                                                                  true
                                                                }, "url" => "tel/modify-whois-pref.json" },
       { "values" => { "order_id" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                    true
                                                                                  }, "url" => "resend-rfa.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "uk/release.json" },
       { "values" => { "order_id" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                    true
                                                                                  }, "url" => "cancel-transfer.json" },
       { "values" => { "order_id" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                    true
                                                                                  }, "url" => "delete.json" },
       { "values" => {}, "http_method" => "post", "validate" => ->(_v) { true }, "url" => "restore.json" },
       { "values" => { "order_id" => "" }, "http_method" => "post", "validate" => lambda { |_v|
                                                                                    true
                                                                                  }, "url" => "de/recheck-ns.json" },
       { "values" => {}, "http_method" => "post", "validate" => lambda { |_v|
                                                                  true
                                                                }, "url" => "dotxxx/association-details.json" }].each { |p| build_method p }
      end
  end
end

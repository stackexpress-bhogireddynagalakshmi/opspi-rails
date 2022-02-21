# frozen_string_literal: true

module ResellerClub
  class Product
    class << self
      extend MethodBuilder

      BASE_URL = "#{ResellerClub::Config.base_url}/products/".freeze

      [{ "values" => {}, "http_method" => "get", "validate" => ->(_v) { true }, "url" => "customer-price.json" }]
        .each { |p| build_method p }
      end
  end
end

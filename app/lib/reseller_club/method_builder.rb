# frozen_string_literal: true

require "typhoeus"
require "open-uri"
require "json"

module ResellerClub
  module MethodBuilder
    def construct_url(params, method)
      params.delete_if { |_k, v| v == "" }
      url = "#{self::BASE_URL}#{method}?"
      url += URI.encode_www_form(params)
      url
    end

    def generate_method_name_from_url(url)
      url.split(".")[0].gsub("/", "_").gsub("-", "_")
    end

    def build_method(data)
      construct_url_bind = method(:construct_url)

      data["method_name"] = generate_method_name_from_url(data["url"]) if data["method_name"].nil?
      define_method data["method_name"] do |params = {}|
        mock = false
        if params.is_a? Hash
          mock = params.delete("test_mock")
          mock ||= params.delete(:test_mock)
        end

        if data["values"].nil?
          data["values"] = {}
        elsif (data["values"].keys.count == 1) && ((data["values"].values)[0] == "")
          case params
          when Hash
            data["values"].merge!(params)
          when String
            data["values"][(data["values"].keys)[0]] = params
          end
        else
          data["values"].merge!(params)
        end

        current_user = if data['values']['customer-id'].present?
                         Spree::User.find_by_reseller_club_customer_id(data['values']['customer-id'])
                       else
                         Spree::User.find_by_email(data['values']['email'])
                       end
        reseller = begin
          current_user.account.store_admin
        rescue StandardError
          nil
        end

        if reseller.present?
          data["values"]['auth-userid'] = reseller.user_key.try(:reseller_club_account_id)
          data["values"]["api-key"] = reseller.user_key.try(:reseller_club_account_key)
        end

        if data["validate"].call(data["values"])
          url = construct_url_bind.call(data["values"], data["url"])
          return url if mock

          ResellerClub::RequestWrapper.new(url, data).call
        else
          raise "Validation failed."
        end
      end
    end
  end
end

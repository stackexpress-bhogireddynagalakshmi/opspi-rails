# frozen_string_literal: true

require "typhoeus"
require 'addressable/uri'

module ResellerClub
  class TyphoeusClient
    attr_reader :url, :data, :success

    def initialize(url, params, _opts = {})
      @data = params
      @url  = url
      @success = false
    end

    def call
      true_false_or_text_bind = method(:true_false_or_text)
      opts = {
        method: data["http_method"].to_sym
      }

      opts[:proxy] = ENV['RESELLER_CLUB_PROXY_SERVER'] if ENV['RESELLER_CLUB_PROXY_SERVER'].present?

      if data["silent"]
        Typhoeus::Request.new(url, opts).run
      else
        Rails.logger.info { "URL:  #{fiter_sensitive_info(url)}" }
        response = Typhoeus::Request.new(url, opts).run
        parsed_response = JSON.parse(true_false_or_text_bind.call(response.body))
        Rails.logger.info { "ResellerClub Response: #{parsed_response}" }

        @success = true if response.code == 200

        { success: @success, response: parsed_response }
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
      case str
      when "true"
        { "response" => true }.to_json
      when "false"
        { "response" => false }.to_json
      when str.to_i.to_s
        { "code" => str }.to_json
      else
        begin
          JSON.parse(str)
        rescue StandardError
          return { "response" => str }.to_json
        end
        str
      end
    end

    def fiter_sensitive_info(url)
      uri = Addressable::URI.parse(url)
      params = uri.query_values
      params = params.reject { |k, _v| Rails.application.config.filter_parameters.include?(k) }
      uri.query_values = params

      uri.to_s
    end
  end
end

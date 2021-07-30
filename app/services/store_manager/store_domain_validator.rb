# frozen_string_literal: true

module StoreManager
  class StoreDomainValidator < ApplicationService
   attr_reader :domain,:domain_with_https,:current_store
   require 'uri'
  
    def initialize(domain, options = {})
      @domain = domain
      @domain_with_https =  "https://#{domain}"
      @current_store = options[:current_store]
    end

    def call
       res = validate_url_format 

       return res if res[0] == false

       validate_uniqueness    
    end

    def validate_url_format
      matchers = @domain.match(/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}$/)

      return [false, 'Not a valid domain'] if matchers.blank?

      return [true]

      # uri = URI.parse(@domain_with_https)
      # resp = uri.kind_of?(URI::HTTP)
      # return [true] if resp == true
      #return [false, 'Not a valid domain']

    # rescue URI::InvalidURIError
    #   [false, 'Not a valid domain.']
    end

    def validate_uniqueness
      return [true] if Spree::Store.where(url: @domain).where.not(url: @current_store.url).size == 0

      return [false, 'Domain already exists.']
    end

  end
end
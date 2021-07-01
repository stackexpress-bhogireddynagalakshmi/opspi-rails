# frozen_string_literal: true

module StoreManager
  class StoreCodeGenerator < ApplicationService
  	attr_accessor :code
    class ExhaustedError < StandardError; end

    def initialize(code, options = {})
      @code = code
    end

    def call
      store_code
    end

    private
    
    def store_code
      TenantManager::TenantHelper.unscoped_query{Spree::Store.last.id+1}
    end

  end
end


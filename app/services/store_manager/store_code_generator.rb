# frozen_string_literal: true

module StoreManager
  class StoreCodeGenerator < ApplicationService
  	attr_accessor :store
    class ExhaustedError < StandardError; end


    def initialize(store, options = {})
      @store = store
    end

   	#generate the code of the store/reseller
    def store_code

    end

  end
end

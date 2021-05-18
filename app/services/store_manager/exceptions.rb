# frozen_string_literal: true

module StoreManager
  module Exceptions
    class InvalidStore < StandardError
      attr_accessor :errors

      def initialize(errors)
        @errors = errors
        super()
      end
      
    end
  end
end

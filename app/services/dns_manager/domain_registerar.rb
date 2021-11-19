module DnsManager  
  class DomainRegisterar
    attr_reader :line_item

    def initialize(line_item,opts={})
      @line_item = line_item
    end

    def call
      DomainRegistrationJob.perform_later(line_item)
    end

  end
end
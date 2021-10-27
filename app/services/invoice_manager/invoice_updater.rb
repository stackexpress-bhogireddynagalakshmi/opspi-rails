module InvoiceManager
  class InvoiceUpdater
    attr_reader :invoice

    def initialize(invoice,options={})
      @invoice = invoice
      @params = options[:params]
    end

    def call
      Rails.logger.info { "Updating Invoice" }
      @invoice.update!(@params)
    end
    
  end
end
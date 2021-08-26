module InvoiceManager
  class InvoiceFeeCalculator 
    attr_reader :invoice,:line_items

    def initialize(invoice,opts={})
      @invoice = invoice
    end

    def calculate_and_save
      @invoice.update(fee_attributes)
    end

    def fee_attributes
      {  balance: @invoice.subscription.price }
    end
  end
end
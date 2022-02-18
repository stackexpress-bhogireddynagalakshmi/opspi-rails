class OrdersPdf

  include Prawn::View
  
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper


  def initialize(order, file_path)
    @order = order
    @file_path = file_path
  end

  def call
    Prawn::Document.generate(@file_path, page_size: 'A4', margin: [20, 30]) do |pdf|
      
      pagination(pdf)
    end
  end

  def pagination(pdf)
    (1..pdf.page_count).to_a.each do |page_no|
      pdf.go_to_page(page_no)
      pdf.text_box "Page #{page_no} of #{pdf.page_count}", at: [(pdf.bounds.right - 50), pdf.bounds.top-10], size: 8
    end
  end

end
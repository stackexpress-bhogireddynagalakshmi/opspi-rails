class OrdersPdf

  include Prawn::View
  
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  HEADER_HEIGHT = 130
  GREY_COLOR = 'ECECEC'
  PAID_COLOR = '97df4a'
  UNPAID_COLOR = 'df554a'
  PAID_STROKE_COLOR = '228B22'
  UNPAID_STROKE_COLOR = '800020'
  TABLE_BORDER_COLOR = '808080'


  def initialize(order, current_spree_user, store, file_path)
    @order = order
    @billing_address = @order.bill_address if @order.has_step?("address")
    @payments = @order.payments.valid if @order.has_step?("payment")
    @invoice = TenantManager::TenantHelper.unscoped_query{current_spree_user.invoices.find_by(order_id: @order.id)}
    @file_path = file_path
    @store = store
    @current_spree_user = current_spree_user
  end

  def call
    Prawn::Document.generate(@file_path, page_size: 'A4', margin: [20, 30]) do |pdf|
      header(pdf)
      order_details(pdf)
      pagination(pdf)
    end
  end

  private

  def header(pdf)
    paid_unpaid_strip(pdf)
    pdf.bounding_box([0, pdf.cursor], width: bounds.width,:height=>HEADER_HEIGHT) do
      store_logo(pdf)
      company_address(pdf)
    end
  end

  def order_details(pdf)
    pdf.bounding_box([0, pdf.cursor], width: bounds.width,:height=>bounds.height - HEADER_HEIGHT) do
      invoice_details(pdf)
      address_details(pdf) if @order.has_step?("address")
      product_details(pdf)
      transaction_details(pdf)
      pdf_generation_details(pdf)
    end
  end

  def invoice_details(pdf)
    pdf.stroke do
      pdf.fill_color GREY_COLOR
      pdf.fill_rectangle [0, pdf.cursor], bounds.width, 55
      pdf.fill_color '000000'
      pdf.bounding_box([3, pdf.cursor], :width => bounds.width, :height => 55) do
        pdf.move_down 5
        pdf.text "<b>Invoice ##{@order.number}</b>", size: 14, inline_format: true
        pdf.move_down 5
        pdf.text "Invoice Date: #{format_date_with_century(@order.completed_at)}", size: 10
        pdf.move_down 5
        pdf.text "Due Date: #{format_date_with_century(@invoice.try(:due_date))}", size: 10
      end
    end
  end

  def address_details(pdf)
    billing_address(pdf)
  end

  def billing_address(pdf)
    pdf.move_down 30
    pdf.text "<b>Invoiced To</b>", inline_format: true, size: 12
    pdf.move_down 10
    pdf.font_size(10) do
      pdf.text @billing_address.try(:full_name)
      unless @billing_address.try(:company).blank?
        pdf.text @billing_address.try(:company)
      end
      pdf.text @billing_address.try(:address1)
      unless @billing_address.try(:address2).blank?
        pdf.text @billing_address.try(:address2)
      end
      city_state_zip = []
      city_state_zip << @billing_address.try(:city).to_s
      if Spree::Config[:address_requires_state]
        city_state_zip << @billing_address.try(:state_text).to_s
      end
      city_state_zip << @billing_address.try(:zipcode).to_s
      pdf.text city_state_zip.join(", ")
      pdf.text @billing_address.try(:country).try(:name)
    end
  end

  def product_details(pdf)
    pdf.move_down 20
    table_data = [["<b>Product</b>", "<b>Quantity</b>", "<b>Price</b>", "<b>Total</b>"]]
    @order.line_items.each do |item|
      table_data << [product_name(pdf, item), item.quantity, item.single_money.to_html, item.display_total.to_s]
    end
    table_data << ["", "", "<b>Sub Total</b>", "<b>#{@order.display_item_total.to_html}</b>"]
    table_data << ["", "", "<b>Total</b>", "<b>#{@order.display_total.to_html}</b>"]
    one_column_width = bounds.width/4
    pdf.table(table_data, :cell_style => { :inline_format => true, size: 10, border_color: TABLE_BORDER_COLOR}, column_widths: [one_column_width]*4) do
      row([0, table_data.size-1, table_data.size-2]).background_color = GREY_COLOR
      columns((0..3).to_a).style(:align => :center)
      row([table_data.size-1, table_data.size-2]).column(2).style(:align => :right)
      # rows((1..table_data.size-1).to_a).column(3).style(:align => :right)
      # rows((1..table_data.size-1).to_a).column(3).style(padding_right: one_column_width/2)
    end
  end

  def transaction_details(pdf)
    pdf.move_down 40
    pdf.text "<b>Transactions</b>", inline_format: true, size: 14
    pdf.move_down 10
    table_data = [["<b>Transaction Date</b>", "<b>Payment Method</b>", "<b>Transaction ID</b>", "<b>Amount</b>"]]
    # @payments = []
    if @payments.any?
      @payments.each do |payment|
        table_data << [format_date_with_century(payment.created_at), get_payment_method(payment), payment.number, amount_with_currency(payment.amount)]
      end
    else
      table_data << [{content: 'No Related Transactions Found', colspan: 4}]
    end
    table_data << ["", "", "<b>Balance</b>", get_balance]
    one_column_width = bounds.width/4
    pdf.table(table_data, :cell_style => { :inline_format => true, size: 10, border_color: TABLE_BORDER_COLOR}, column_widths: [one_column_width]*4) do
      row([0, table_data.size-1]).background_color = GREY_COLOR
      columns((0..3).to_a).style(:align => :center)
      row([table_data.size-1]).column(2).style(:align => :right)
      # rows((1..table_data.size-1).to_a).column(3).style(:align => :right)
      # rows((1..table_data.size-1).to_a).column(3).style(padding_right: one_column_width/2)
    end
  end

  def product_name(pdf, item)
    data = ""
    TenantManager::TenantHelper.unscoped_query do
      data = "#{item.name} \n #{render_domain_name(item.product,item).to_s}"
      unless item.variant.is_master?
        item.variant.option_values.sort { |ov| ov.option_type.position }.each do |ov|
          data += "\n• #{ov.option_type.presentation}: #{ov.name.titleize}"
        end
      end
    end
    data
  end

  def get_payment_method(payment)
    payment_method = []
    source = payment.source
    if source.is_a?(Spree::CreditCard)
      if source.last_digits
        payment_method << "#{Spree.t(:ending_in)} #{source.last_digits}"
      end
      payment_method << "#{source.name}"
    else
      payment_method << payment.payment_method.name
    end
    payment_method.compact.join(" ")
  end

  def get_balance
    total_payment = @payments.map(&:amount).compact.sum
    total_amount = @order.display_item_total.money.to_f
    Spree::Money.new(total_amount - total_payment, currency: @order.display_item_total.money.currency.iso_code).to_html
  end

  def pdf_generation_details(pdf)
    pdf.move_down 40
    pdf.text "PDF Generated on #{format_date_with_century(Date.today)}", size: 10, align: :center
  end

  def payment_state_color
    order_paid? ? PAID_COLOR : UNPAID_COLOR
  end

  def payment_state_text
    order_paid? ? "PAID" : "UNPAID"
  end

  def payment_state_stroke_color
    order_paid? ? PAID_STROKE_COLOR : UNPAID_STROKE_COLOR
  end

  def payment_state_bounds(pdf)
    order_paid? ? [bounds.width-30, pdf.cursor-37] : [bounds.width-45, pdf.cursor-37]
  end

  def amount_with_currency(amount)
    amount = amount.to_f
    Spree::Money.new(amount, currency: @order.display_item_total.money.currency.iso_code).to_html
  end

  def order_paid?
    (@order.payment_state == 'paid')
  end

  def paid_unpaid_strip(pdf)
    pdf.rotate(320, origin: [540, 800]) do
      pdf.fill_color payment_state_color
      pdf.stroke_color payment_state_stroke_color
      pdf.fill_and_stroke_rectangle [bounds.width-130, pdf.cursor-10], 220, 40
      pdf.fill_color 'FFFFFF'
      pdf.draw_text payment_state_text, size: 20, at: payment_state_bounds(pdf), style: :bold
      pdf.fill_color '000000'
    end
  end

  def store_logo(pdf)
    pdf.bounding_box([0, pdf.cursor], width: bounds.width,:height=>80) do
      pdf.move_down 20
      if @store.logo.attached? && @store.logo.image?
        pdf.image StringIO.open(@store.logo.download), width: 200, height: 60
      else
        pdf.image "#{Rails.root}/app/assets/images/OpsPi-logo.jpg", width: 200, height: 60
      end
    end
  end

  def company_address(pdf)
    pdf.bounding_box([0, pdf.cursor], width: bounds.width,:height=>50) do
      if @current_spree_user.store_admin?
        admin = Spree::User.select(&:superadmin?).first
        pdf.text "#{admin.account.orgainization_name}", size: 12, align: :right, style: :bold
        unless admin.addresses.first.nil?
          pdf.text "#{admin.addresses.first.address1}, #{admin.addresses.first.address2}", size: 10, align: :right
          pdf.text "#{admin.addresses.first.city}, #{admin.addresses.first.state.abbr} #{admin.addresses.first.zipcode}", size: 10, align: :right
        end
      else
        pdf.text "#{@current_spree_user.account.orgainization_name}", size: 12, align: :right, style: :bold
        unless @current_spree_user.addresses.first.nil?
          pdf.text "#{@current_spree_user.addresses.first.address1}, #{@current_spree_user.addresses.first.address2}", size: 10, align: :right
          pdf.text "#{@current_spree_user.addresses.first.city}, #{@current_spree_user.addresses.first&.state&.abbr} #{@current_spree_user.addresses&.first&.zipcode}", size: 10, align: :right
        end
      end
    end
  end

  def pagination(pdf)
    (1..pdf.page_count).to_a.each do |page_no|
      pdf.go_to_page(page_no)
      pdf.text_box "Page #{page_no} of #{pdf.page_count}", at: [(pdf.bounds.right - 50), pdf.bounds.bottom+10], size: 8
    end
  end

end
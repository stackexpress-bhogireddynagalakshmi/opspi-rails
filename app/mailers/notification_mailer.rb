class NotificationMailer < Spree::BaseMailer
  
  def unpaid_invoice_reminder
    @invoice = params[:invoice]
    @user    = params[:user]
  end

  def pannel_access_disabled
    @invoice = params[:invoice]
    @user    = params[:user]
  end

end

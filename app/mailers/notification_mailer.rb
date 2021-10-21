class NotificationMailer < Spree::BaseMailer
  
  def unpaid_invoice_reminder
    @invoice = params[:invoice]
    @user    = params[:user]
    @current_store =  @user.account.spree_store
    @payment_source = @invoice.user.payment_sources.detect{|x|x.default?}

    mail to: @user.email, from: @current_store.mail_from_address, subject: 'Unpaid Invoice Reminder', store_url: @current_store.url
  end

  def pannel_access_disabled
    @invoice        = params[:invoice]
    @user           = params[:user]
    @current_store  = @user.account.spree_store
    @panel          = params[:panel] 

    mail to: @user.email, from: @current_store.mail_from_address, subject: "#{@panel} Account Disabled", store_url: @current_store.url
  end


  def pannel_access_enabled
    @invoice        = params[:invoice]
    @user           = params[:user]
    @current_store  = @user.account.spree_store
    @panel          = params[:panel] 

    mail to: @user.email, from: @current_store.mail_from_address, subject: "#{@panel} Account Enabled", store_url: @current_store.url
  end

end

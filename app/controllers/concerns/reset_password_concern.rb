module ResetPasswordConcern
  extend ActiveSupport::Concern
    
    def reset_password
      @password = SecureRandom.hex
      case params[:type]
      when 'create_mail_box'
        mailboxes = mail_user_api.all
        mailboxes = mailboxes[:response].response
        mailbox   = mailboxes.detect { |x| x.email == params[:email] }
        @response = mail_user_api.update(mailbox.mailuser_id, { password: @password })
      when 'create_ftp_account'
        ftp_users = ftp_user_api.all
        ftp_users = ftp_users[:response].response
        ftp_user  = ftp_users.detect { |x| x.username == params[:email] }
        @response = ftp_user_api.update(ftp_user.ftp_user_id, { password: @password })
      when 'create_database'
        prefix = (params[:source] == "wizard") ? "c#{current_spree_user.isp_config_id}_" : ""
        db_users  = db_user_api.all
        db_users  = db_users[:response].response
        db_user   = db_users.detect { |x| x.database_user == "#{prefix}#{params[:email]}" }
        @response = db_user_api.update_database_user_password(
          db_user.database_user_id, { database_password: @password }
          )
      end

    render template: '/spree/admin/shared/spree/admin/password/reset_password.js.erb'
    rescue => e
      Rails.logger.error { e.message }
      puts e.backtrace
      @response = {success: false, error: "something went wrong. Please try after sometime."}
    end

end
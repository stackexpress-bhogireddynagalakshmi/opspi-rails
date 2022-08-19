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
        if params[:server_type] == 'linux'
          ftp_users = ftp_user_api.all
          ftp_users = ftp_users[:response].response
          ftp_user  = ftp_users.detect { |x| x.username == params[:email] }
          @response = ftp_user_api.update(ftp_user.ftp_user_id, { password: @password })
        else
          ftp_users = ftp_user_api.all
          ftp_users = ftp_users.body[:get_ftp_accounts_response][:get_ftp_accounts_result][:ftp_account]  || []
          ftp_users = [ftp_users] if ftp_users.is_a?(Hash)
          ftp_user  = ftp_users.detect { |x| x[:name] == params[:email] }
          @response = ftp_user_api.update(ftp_user[:id], { password: @password, username: ftp_user[:name], can_read: ftp_user[:can_read], can_write: ftp_user[:can_write], folder: ftp_user[:folder]})
        end
      when 'create_database'
        db_user_name = current_spree_user.user_databases.where(database_name: params[:email]).first.database_user
        if params[:server_type] == 'windows'
          windows_database(db_user_name,params[:email])
        else
          linux_database(db_user_name)
        end
      end

    render template: '/spree/admin/shared/spree/admin/password/reset_password.js.erb'
    rescue => e
      Rails.logger.error { e.message }
      puts e.backtrace
      @response = {success: false, error: "something went wrong. Please try after sometime."}
    end

    def linux_database(db_user_name)
      db_users  = db_user_api.all
      db_users  = db_users[:response].response
      db_user   = db_users.detect { |x| x.database_user == db_user_name }
      @response = db_user_api.update_database_user_password(
        db_user.database_user_id, { database_password: @password }
        )
    end

    def windows_database(db_user_name,database_name)
      db_users  = current_spree_user.solid_cp.sql_server.all_db_users
      db_users = db_users.body[:get_sql_users_response][:get_sql_users_result][:sql_user] || []
      db_users = [db_users] if db_users.is_a?(Hash)
      db_user   = db_users.detect { |x| x[:name] == db_user_name }
      @response = current_spree_user.solid_cp.sql_server.update_database_user_password(
        db_user[:id], { database_password: @password, database_name: database_name }
        )
    end

end
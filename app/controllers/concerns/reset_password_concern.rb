module ResetPasswordConcern
  extend ActiveSupport::Concern
    
    def reset_password
      @password = SecureRandom.urlsafe_base64


      @user_domain = current_spree_user.user_domains.find(params[:user_domain_id]) 

      if params[:type].include?('mail_box')
        @mailbox  = @user_domain.user_mailboxes.find_by_id(params[:id]) ||  @user_domain.user_mailboxes.where(email: params[:email]).last
        @response = mail_user_api.update(@mailbox.id, { password: @password })
      elsif params[:type].include?('ftp_account')
        @ftp_user  = @user_domain.user_ftp_users.find_by_id(params[:id]) ||  @user_domain.user_ftp_users.where(username: params[:email]).last

        if @user_domain.linux?
          @response = ftp_user_api.update(@ftp_user.id, { password: @password })
        else
          @response = ftp_user_api.destroy(@ftp_user.id) if @ftp_user.present?
          @response = ftp_user_api.create({ username: @ftp_user.username, password: @password, folder: @user_domain.remote_folder_path }, user_domain: @user_domain)  
          @ftp_user = @user_domain.user_ftp_users.where(username: @ftp_user.username).last
        end
      elsif params[:type].include?('database')
        @database = @user_domain.user_databases.find_by_id(params[:id]) ||  @user_domain.user_databases.where(database_name: params[:email]).last

        if @database.my_sql?
          reset_linux_db_password(@database)
        elsif @database.ms_sql2019?
          reset_windows_db_password(@database)
        end
      end

    render template: '/spree/admin/shared/spree/admin/password/reset_password'
    rescue => e
      ErrorLogger.log_exception(e)
      @response = {success: false, error: "something went wrong. Please try after sometime."}
    end

    def reset_linux_db_password(database)
      
      db_users  = db_user_api.all
      db_users  = db_users[:response].response
      db_user   = db_users.detect { |x| x.database_user == database.database_user }
      @response = db_user_api.update_database_user_password(
        db_user.database_user_id, { database_password: @password }
        )
    end

    def reset_windows_db_password(database)
      db_users  = current_spree_user.solid_cp.sql_server.all_db_users
      db_users = db_users.body[:get_sql_users_response][:get_sql_users_result][:sql_user] || [] rescue []
    
      if db_users .present?
        db_users = [db_users] if db_users.is_a?(Hash)
        db_user   = db_users.detect { |x| x[:name] == database.database_user }
        @response = current_spree_user.solid_cp.sql_server.delete_sql_user(db_user[:id]) if db_user.present?
      end
      
      @response = current_spree_user.solid_cp.sql_server.add_sql_user({database_username: database.database_user,database_name:database.database_name,  database_password: @password})

      @database = @user_domain.user_databases.where(database_user: @database.database_user).last
      return { success: false,  error: "something went wrong. Please try after sometime."} if @response.nil?
    end

end
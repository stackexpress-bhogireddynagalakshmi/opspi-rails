module DatabaseConcern
  def formatted_db_user_name(database_username)
    if Rails.env == 'development'
      "du_dev_#{database_username.to_s.rjust(8, padstr='0')}"
    else
      "du_#{database_username.to_s.rjust(8, padstr='0')}"
    end
  end

  def formatted_db_name(database_name)
    "#{UserDatabase.database_name_prefix(user)}#{database_name}"
  end
end
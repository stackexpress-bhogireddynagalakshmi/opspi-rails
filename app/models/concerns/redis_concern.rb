module RedisConcern
  extend ActiveSupport::Concern

  def get_password(panel='solid_cp')
    Sidekiq.redis{|conn|conn.get("spree_user_id_#{user.id}_#{panel}")}
  end

  def set_password(panel='solid_cp',password=nil)
    password = SolidCp::Misc.password_generator if password.blank?
    Sidekiq.redis{|conn|conn.set("spree_user_id_#{user.id}_#{panel}", password)}
  end

  def get_username   
    return user.isp_config_username if user.isp_config_username.present?

    create_uniq_isp_config_username
  end

  def remove_passoword_key(panel='solid_cp')
    Sidekiq.redis{|conn|conn.del("spree_user_id_#{user.id}_#{panel}")}
  end


  def create_uniq_isp_config_username
    return user.isp_config_username if user.isp_config_username.present?

    loop do
      username = "u_#{SecureRandom.hex(6)}"
      isp_user = Spree::User.find_by_isp_config_username(username)

      if isp_user.blank?
        user.update_column(:isp_config_username,username)

        break
      end
    end

    user.isp_config_username
  end

end


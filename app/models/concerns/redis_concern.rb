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
    
    "#{user.email[/^[^@]+/]}_#{user.id}"
  end

  def remove_passoword_key(panel='solid_cp')
    Sidekiq.redis{|conn|conn.del("spree_user_id_#{user.id}_#{panel}")}
  end
    
end
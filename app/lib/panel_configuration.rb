module PanelConfiguration
  def api_username(user)
    panel_id = panel_id_for(user)
    config_value_for(panel_id, username_key)
  end

  def api_password(user)
    panel_id = panel_id_for(user)
    config_value_for(panel_id, password_key)
  end

  def api_url(panel_id)
    config_value_for(panel_id, url_key)
  end

  def api_web_server_ip(user)
    panel_id = panel_id_for(user)
    config_value_for(panel_id, web_server_ip_key)
  end

  def config_value_for(panel_id, key)
    value = PanelConfig.where(panel_id: panel_id, key: key).last&.value

    return value if value.present?

    raise "Value for #{key} with Panel ID #{panel_id} does not exist."
  end

  def panel_id_for(user)
    user.panel_config[server_type_key] 
  end
end
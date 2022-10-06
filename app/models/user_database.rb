class UserDatabase < ApplicationRecord
  include PanelConfiguration

  belongs_to :user, class_name: 'Spree::User'

  validates :database_name, presence: true
  # validates :database_user, presence: true

  after_create_commit :update_status

  enum database_type: {
    my_sql: 1,
    ms_sql2019: 2
  }

  enum status: {
    in_progress: 1,
    active: 2,
    failed: 3,
    suspended: 4
  }

  def database_host
    if my_sql?
      config_value_for(user.panel_config["database_mysql"], 'MYSQL_SERVER_HOSTNAME')
    elsif ms_sql2019?
      config_value_for(user.panel_config["database_mssql"], 'MSSQL_SERVER_HOSTNAME')
    end
  end

  def database_port
    if my_sql?
      config_value_for(user.panel_config["database_mysql"], 'MYSQL_SERVER_PORT')
    elsif ms_sql2019?
     config_value_for(user.panel_config["database_mssql"], 'MSSQL_SERVER_PORT')
    end    
  end

  def update_status
    self.update(status: 'in_progress')
  end

  def self.database_name_prefix(user)
    "c#{user.id}_"
  end

end

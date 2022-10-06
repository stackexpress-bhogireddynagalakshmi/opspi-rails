class PanelSeeder
  require 'csv'

  def self.seed
    new.seed
  end

  def seed
    puts "Panel Seeding Started"
    seed_panel_types
    seed_panels
    seed_ispconfig_variables
    seed_solid_variables
    seed_active_panel
    seed_user_panel_config
    seed_default_panel_config
    puts "Panel Seeding Completed"
  end

  PANEL_TYPE = ['ispconfig','solidcp', 'hsphere']

  def seed_panel_types
    PANEL_TYPE.each do |type|
      PanelType.find_or_create_by({name: type})
    end
  end

  def seed_panels
    PANEL_TYPE.each do |type|
      panel_type = PanelType.where(name: type).first
      Panel.find_or_create_by({panel_type_id: panel_type.id})
    end
  end


  def seed_ispconfig_variables
    begin
      data = CSV.read("#{Rails.root}/db/data/isp_config_cluster.csv")

      data.each do |row|
        next if row[0] == 'key'

        panel_config = PanelConfig.where(panel_id: row[2], key: row[0]).first_or_create
        panel_config.value = row[1]
        panel_config.save
      end

    rescue Errno::ENOENT => e
      Rails.logger.error {"#{Rails.root}/db/data/isp_config_cluster.csv does not exists. Skipping seed for ispconfig."}
    end
  end

  def seed_default_panel_config
    begin
      # data = CSV.read("#{Rails.root}/db/data/isp_config_cluster.csv")
      CSV.foreach("#{Rails.root}/db/data/isp_config_cluster.csv", :headers => true, :quote_char => '"') { |r| puts r.to_hash }
      # data.each do |row|
      #   next if row[0] == 'key'

      #   panel_config = PanelConfig.where(panel_id: row[2], key: row[0]).first_or_create
      #   panel_config.value = row[1]
      #   panel_config.save
      # end

    rescue Errno::ENOENT => e
      Rails.logger.error {"#{Rails.root}/db/data/isp_config_cluster.csv does not exists. Skipping seed for ispconfig."}
    end
  end

  def seed_solid_variables
    begin
      data = CSV.read("#{Rails.root}/db/data/solid_cp_config_cluster.csv")

      data.each do |row|
        next if row[0] == 'key'

        panel_config = PanelConfig.where(panel_id: row[2], key: row[0]).first_or_create
        panel_config.value = row[1]
        panel_config.save
      end
    rescue Errno::ENOENT => e
       Rails.logger.error {"#{Rails.root}/db/data/solid_cp_config_cluster.csv does not exists. Skipping seed for solidcp."}
    end
  end

  def seed_active_panel 
    service_hash = {
      dns: linux_panel.id,
      mail: linux_panel.id,
      web_linux: linux_panel.id,
      database_mysql: linux_panel.id,
      web_windows: windows_panel.id,
      database_mssql: windows_panel.id
     }

    service_hash.each do |k,v|
        active_panel = ActivePanel.find_by_service(k)

        if active_panel.blank?
          ActivePanel.create({
            service: k,
            panel_id: v
          })
        end
    end
  end

  def seed_user_panel_config
     Spree::User.all.each do |user|
      next if user.panel_config.present?

      user.panel_config = ActivePanel.panel_configs_json
      user.save
    end
  end


  def truncate_panel_data
    ActiveRecord::Base.connection.execute("TRUNCATE table panels;")
    ActiveRecord::Base.connection.execute("TRUNCATE table active_panels;")
    ActiveRecord::Base.connection.execute("TRUNCATE table panel_configs;")
    ActiveRecord::Base.connection.execute("TRUNCATE table panel_types;")

    Spree::User.all.each do |user|
      user.panel_config = nil
      user.save
    end
  end

  private  
  def linux_panel
    Panel.joins(:panel_type).where(panel_types: {name: 'ispconfig'}).first  
  end

  def windows_panel
    Panel.joins(:panel_type).where(panel_types: {name: 'solidcp'}).first  
  end
end
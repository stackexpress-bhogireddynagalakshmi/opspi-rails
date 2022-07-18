require 'csv'

def seed_solid_cp_cluster
    csv_file_path = "#{Rails.root}/db/data/solid_cp_config_cluster.csv"

    return "File not exists" unless File.exist?(csv_file_path)

    f = File.new(csv_file_path, 'r')
    csv = CSV.new(f)
    headers = csv.shift

    @start = Time.now
    count = 0
    puts "SolidCp Cluster import Started at #{@start}"

    csv.each do |row|
      if SolidCpClusterConfig.find_by_key(row[0]).present?
        puts "#{row[0]} already exist"
        next
      end
      solid_cp_information = {
        key: row[0],
        value: row[1],
        cluster_id: row[2]
      }
     cluster_config_obj = SolidCpClusterConfig.new(solid_cp_information)
     cluster_config_obj.save!

     count+=1
    end
    puts "{total_time: #{(Time.now - @start)},count: #{count}}"
end
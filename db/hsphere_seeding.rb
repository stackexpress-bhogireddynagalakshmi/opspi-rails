require 'csv'

def seed_hsphere_cluster
    csv_file_path = "#{Rails.root}/db/data/hpshere_cluster_data.csv"

    return "File not exists" unless File.exist?(csv_file_path)

    f = File.new(csv_file_path, 'r')
    csv = CSV.new(f)
    headers = csv.shift

    @start = Time.now
    count = 0
    puts "Hsphere Cluster import Started at #{@start}"

    csv.each do |row|
      if HsphereClusterConfig.find_by_value(row[1]).present?
        puts "#{row[1]} already exist"
        next
      end
      hsphere_information = {
        key: row[0],
        value: row[1],
        cluster_id: row[2]
      }
     cluster_config_obj = HsphereClusterConfig.new(hsphere_information)
     cluster_config_obj.save!

     count+=1
    end
    puts "{total_time: #{(Time.now - @start)},count: #{count}}"
end
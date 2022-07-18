require 'csv'

def seed_isp_config_cluster
    csv_file_path = "#{Rails.root}/db/data/isp_config_cluster.csv"

    return "File not exists" unless File.exist?(csv_file_path)

    f = File.new(csv_file_path, 'r')
    csv = CSV.new(f)
    headers = csv.shift

    @start = Time.now
    count = 0
    puts "IspConfig Cluster import Started at #{@start}"

    csv.each do |row|
      if IspConfigClusterConfig.find_by_key(row[0]).present?
        puts "#{row[0]} already exist"
        next
      end
      isp_config_information = {
        key: row[0],
        value: row[1],
        cluster_id: row[2]
      }
     cluster_config_obj = IspConfigClusterConfig.new(isp_config_information)
     cluster_config_obj.save!

     count+=1
    end
    puts "{total_time: #{(Time.now - @start)},count: #{count}}"
end
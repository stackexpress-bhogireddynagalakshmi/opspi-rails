module ImportManager
    class HsphereClusterImporter < BaseImporter
      require 'csv'    

      def initialize(file,options={})
        @file = file
      end
  
      def call
       
          @start = Time.now
          count = 0
          Rails.logger.debug {"Hsphere Cluster import Started at #{@start}"}

          @file.each_slice(1000).with_index do |clusters, index|
            clusters.each do |cluster|
              next if cluster[0] == 'key'
              if HsphereClusterConfig.find_by_value(cluster[1]).present?
                Rails.logger.info { "#{cluster[1]} already exist" }
                next
              end
              cluster_config_obj = HsphereClusterConfig.new({
                key: cluster[0],
                value: cluster[1],
                cluster_id: cluster[2]

              })

              cluster_config_obj.save!
              count+=1
            end
          end
          return {total_time: (Time.now - @start),count: count}
      end
  
    end
  end
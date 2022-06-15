module ImportManager
    class HsphereClusterImporter 

      def call
       
          @start = Time.now
          count = 0
          Rails.logger.debug {"Hsphere Cluster import Started at #{@start}"}
          clusters = [{key: "login_url", value: "https://cp.myhsphere.biz", cluster_id: 1}, {key: "login_url", value: "https://cp.gohsphere.com", cluster_id: 2}]

          clusters.each do |cluster|

            if HsphereClusterConfig.find_by_value(cluster[:value]).present?
              Rails.logger.info { "#{cluster[:value]} already exist" }
              next
            end
            cluster_config_obj = HsphereClusterConfig.new({
              key: cluster[:key],
              value: cluster[:value],
              cluster_id: cluster[:cluster_id]

            })

            cluster_config_obj.save!
            count+=1
          end
          return {total_time: (Time.now - @start),count: count}
      end
  
    end
  end
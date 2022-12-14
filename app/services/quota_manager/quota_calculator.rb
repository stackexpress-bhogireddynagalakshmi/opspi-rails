# frozen_string_literal: true

module QuotaManager
    class QuotaCalculator < ApplicationService
      require 'action_view'
      include ActionView::Helpers::NumberHelper
      attr_reader :user, :product_id, :subscription
  
      def initialize(subscription, opts = {})
        @subscription       = subscription
        @user               = @subscription.user
        @product_id         = @subscription.product_id
      end
  
      def call
        ActiveRecord::Base.transaction do
          product = Spree::Product.where(id:product_id).first
          # if product.linux?
          if user.isp_config_id.present? 
            @domain_list = get_domain_list
            @domain_response   = get_domain_quota
            @mail_response     = get_mail_quota 
            @database_response = get_database_quota
            
            @web_traffic       = get_web_traffic
            @ftp_traffic       = get_ftp_traffic
            ## mail
          # end
          # if user.isp_config_id.present?
            if @domain_response[:success] && @mail_response[:success] && @database_response[:success] && @domain_list[:success] && @web_traffic[:success] && @ftp_traffic[:success]


              if user.solid_cp_id.present?
                return if user.packages.first.try(:solid_cp_package_id).nil?
    
                # context = get_solid_cp_package_context
                
                solid_cp_quota_dspace = get_solid_cp_used_space
                solid_cp_quota_bwidth = get_solid_cp_used_bandwidth

                quota_array = solid_cp_quota_dspace.body[:get_package_diskspace_response][:get_package_diskspace_result][:diffgram]
                
                bandwidth_quota = solid_cp_quota_bwidth.body[:get_package_bandwidth_response][:get_package_bandwidth_result][:diffgram]
                
                if bandwidth_quota[:new_data_set].present?
                  @table_recs = bandwidth_quota[:new_data_set][:table]
                  @table_recs = [@table_recs] if @table_recs.is_a?(Hash)
                  @web_bandwidth = @table_recs.collect{|x| x[:bytes_total] if x[:group_name] == 'Web'}.compact.first
                  # @ftp_bandwidth = @table_recs.collect{|x| x[:bytes_total] if x[:group_name] == 'FTP'}.compact.first
                end

                if quota_array[:new_data_set].present?
                  @disk_space = quota_array[:new_data_set][:table]
                  @disk_space = [@disk_space] if @disk_space.is_a?(Hash)
                  # @file_disk_space = @disk_space.collect {|x| x[:diskspace_bytes] if x[:group_name] == 'OS'}.compact.first
                  @web_disk_space = @disk_space.collect {|x| x[:diskspace_bytes] if x[:group_name] == 'Web'}.compact.first
                  @ms_db_disk_space =  @disk_space.collect {|x| x[:diskspace_bytes] if x[:group_name] == 'MsSQL2019'}.compact.first
                end
                # @disk_space = quota_array.collect{ |x| x[:quota_used_value] if x[:quota_name] == 'OS.Diskspace'}
                # @bandwidth = quota_array.collect{ |x| x[:quota_used_value] if x[:quota_name] == 'OS.Bandwidth'}
              end
           
              domain    = get_quota_info(@domain_response[:response])
              mail      = get_quota_info(@mail_response[:response])
              database  = get_quota_info(@database_response[:response])

              domain_space = domain[:space].collect{|x| kb_to_bytes(x)}
              database_space = database[:space].collect{|x| kb_to_bytes(x)}


              wb_traffic_bytes  = get_bytes(@web_traffic[:response])
              ftp_traffic_bytes = get_bytes(@ftp_traffic[:response])

              # @quota = convert_to_json({isp_disk: {web: number_to_human_size(domain_space.inject(0, :+)), mail: number_to_human_size(mail[:space].inject(0, :+)), database: number_to_human_size(database_space.inject(0, :+))},
              # isp_bandwidth: {web: number_to_human_size(wb_traffic_bytes), ftp: number_to_human_size(ftp_traffic_bytes), mail: 0}, 
              # solid_disk: {file: number_to_human_size(@file_disk_space), web: number_to_human_size(@web_disk_space), database: number_to_human_size(@ms_db_disk_space)}, solid_band: {web: number_to_human_size(@web_bandwidth),ftp: number_to_human_size(@ftp_bandwidth)}})
              total_usage = {
                disk_space:{
                  web_linux: number_to_human_size(domain_space.inject(0, :+)),
                  web_windows: number_to_human_size(@web_disk_space),
                  mail: number_to_human_size(mail[:space].inject(0, :+)),
                  database_mysql: number_to_human_size(database_space.inject(0, :+)),
                  database_mssql: number_to_human_size(@ms_db_disk_space)
                },
                bandwidth:{
                  ftp: number_to_human_size(ftp_traffic_bytes),
                  web_linux: number_to_human_size(wb_traffic_bytes),
                  web_windows:number_to_human_size(@web_bandwidth),
                  mail: 0
                }
              }
              database_mysql = @database_response[:response].collect{|x| [x[:database_name],x[:used]]}.compact.to_h
              domain_list = @domain_list[:response].response.collect{|x| x[:origin]}
              website_quota = @domain_response[:response].collect{|x| [x[:domain],x[:used]]}
              @all_domains = []
              
              domain_list.each do |domain|
                web_disk = @domain_response[:response].collect{|x| x[:used] if x[:domain] == sanitize_domain(domain)}.compact.first
                web_bw = @web_traffic[:response].to_a.collect{|x| x.last[:this_year] if x.first == sanitize_domain(domain)}.compact.first
                ftp_bw = @ftp_traffic[:response].to_a.collect{|x| x.last[:this_year] if x.first == sanitize_domain(domain)}.compact.first
                hash_params = {
                  domain: sanitize_domain(domain),
                  web_linux: kb_to_bytes(web_disk.to_i),
                  web_bw: web_bw,
                  ftp_bw: ftp_bw
                }
                @all_domains << domain(hash_params)
              end
                
              @quota = convert_to_hash(total_usage,database_mysql)
              quota_usage_obj = QuotaUsage.new({
                user_id: user.id,
                product_id: product_id,
                quota_used: @quota
              })

              if existing_quota.blank?
                quota_usage_obj.save!
              else
                existing_quota.update(quota_used: @quota)
              end
            end
          end
        end
      end
      private

      def sanitize_domain(domain)
        domain.chomp('.')
      end

      def convert_to_hash(total_usage,database_mysql)
       usage_hash = { usage: {
        domains: @all_domains,
        databases: {
          database_mysql: database_mysql
        },
        total_usage: total_usage
       }
      }
      end

      def domain(resources ={})
        domains = {
          "#{resources[:domain]}": {
            disk_space: domain_disk_space(resources),
            bandwidth:  domain_bandwidth(resources)
          }
        }
      end

      def domain_bandwidth(bandwidth)
        {
        ftp: bandwidth[:ftp_bw],
        web_linux: bandwidth[:web_bw],
        mailboxes: {}
        }
      end

      def domain_disk_space(disk)
        {
        web_linux: disk[:web_linux],
        mailboxes: mailbox_disk_space(disk[:domain])
        }
      end

      def mailbox_disk_space(domain_name)
        mailbox_quota.collect{|x| x if x.first.split('@')[1] == domain_name}.compact.to_h
      end

      def get_solid_cp_package_context
        SolidCp::Package.new(user).get_package_context
      end

      def get_solid_cp_used_space
        SolidCp::Package.new(user).get_package_diskspace
      end

      def get_solid_cp_used_bandwidth
        SolidCp::Package.new(user).get_package_bandwidth
      end

      def existing_quota
        QuotaUsage.where(user_id: user.id,product_id: product_id).first
      end


      def mailbox_quota
        @mail_response[:response].collect{|x| [x[:email],x[:used]]}
      end

      def solid_cp_quota_value(value)
        if value.nil? 
          val =  0 
        elsif value.is_a?(Array)
          val = value.compact.first
        else 
          val = value
        end
      end
  
      def get_quota_info(quota_data)
        count = quota_data.count
        used_space = quota_data.collect { |x| x.used.to_i }
        return {count: count, space: used_space}
      end

      def get_bytes(traffic_data)
        bytes = traffic_data.collect{|key,value| (value.this_year).to_i }
        bytes.inject(0, :+)
      end

      def kb_to_bytes(kb)
        kb * 1000
      end
  
      def get_domain_list
        Rails.logger.info { "Domain list called" }
        IspConfig::Dns::HostedZone.new(user).all_zones
      end

      def get_domain_quota
        Rails.logger.info { "Domain quota called" }
        IspConfig::QuotaDashboard.new(user).domain_quota
      end

      def get_mail_quota
        Rails.logger.info { "Mail quota called" }
        IspConfig::QuotaDashboard.new(user).mail_quota
      end

      def get_database_quota
        Rails.logger.info { "Database quota called" }
        IspConfig::QuotaDashboard.new(user).database_quota
      end
  
      def get_web_traffic
        Rails.logger.info { "web traffic quota called" }
        IspConfig::QuotaDashboard.new(user).web_traffic
      end

      def get_ftp_traffic
        Rails.logger.info { "Ftp traffic quota called" }
        IspConfig::QuotaDashboard.new(user).ftp_traffic
      end
      
  
    end
  end
  
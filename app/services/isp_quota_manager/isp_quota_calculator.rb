# frozen_string_literal: true

module IspQuotaManager
    class IspQuotaCalculator < ApplicationService
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
            @domain_response   = get_domain_quota
            @mail_response     = get_mail_quota
            @database_response = get_database_quota

            @web_traffic       = get_web_traffic
            @ftp_traffic       = get_ftp_traffic
            
          end

          if user.solid_cp_id.present?
            return if user.packages.first.try(:solid_cp_package_id).nil?

            solid_cp_quota_dspace = get_solid_cp_used_space
            solid_cp_quota_bwidth = get_solid_cp_used_bandwidth

            quota_array = solid_cp_quota_dspace.body[:get_package_diskspace_response][:get_package_diskspace_result][:diffgram][:new_data_set][:table]
            
            bandwidth_quota = solid_cp_quota_bwidth.body[:get_package_bandwidth_response][:get_package_bandwidth_result][:diffgram]
            
            if bandwidth_quota[:new_data_set].present?
              @table_recs = bandwidth_quota[:new_data_set][:table]
              @table_recs = [@table_recs] if @table_recs.is_a?(Hash)
              @web_bandwidth = @table_recs.collect{|x| x[:bytes_total] if x[:group_name] == 'Web'}.compact.first
              @ftp_bandwidth = @table_recs.collect{|x| x[:bytes_total] if x[:group_name] == 'FTP'}.compact.first
            end
            if quota_array.is_a?(Hash)
              @file_disk_space = quota_array[:diskspace_bytes]
            else
              @file_disk_space = quota_array.collect {|x| x[:diskspace_bytes] if x[:group_name] == 'OS'}.compact.first
              @web_disk_space = quota_array.collect {|x| x[:diskspace_bytes] if x[:group_name] == 'Web'}.compact.first
              @ms_db_disk_space = quota_array.collect {|x| x[:diskspace_bytes] if x[:group_name] == 'MsSQL2019'}.compact.first
            end
            # @disk_space = quota_array.collect{ |x| x[:quota_used_value] if x[:quota_name] == 'OS.Diskspace'}
            # @bandwidth = quota_array.collect{ |x| x[:quota_used_value] if x[:quota_name] == 'OS.Bandwidth'}
          end

            # quota_array = solid_cp_quota.body[:get_package_context_response][:get_package_context_result][:quotas_array][:quota_value_info]

          if user.isp_config_id.present? || user.solid_cp_id.present?
            if @domain_response[:success] && @mail_response[:success] && @database_response[:success]

              domain    = get_quota_info(@domain_response[:response])
              mail      = get_quota_info(@mail_response[:response])
              database  = get_quota_info(@database_response[:response])

              domain_space = domain[:space].collect{|x| kb_to_bytes(x)}
              database_space = database[:space].collect{|x| kb_to_bytes(x)}

              # total_isp_bytes = number_to_human_size([domain_space,mail[:space],database_space].reduce([], :concat).inject(0, :+))

              wb_traffic_bytes  = get_bytes(@web_traffic[:response])
              ftp_traffic_bytes = get_bytes(@ftp_traffic[:response])

              @quota = convert_to_json({isp_disk: {web: number_to_human_size(domain_space.inject(0, :+)), mail: number_to_human_size(mail[:space].inject(0, :+)), database: number_to_human_size(database_space.inject(0, :+))},
              isp_bandwidth: {web: number_to_human_size(wb_traffic_bytes), ftp: number_to_human_size(ftp_traffic_bytes), mail: 0}, 
              solid_disk: {file: number_to_human_size(@file_disk_space), web: number_to_human_size(@web_disk_space), database: number_to_human_size(@ms_db_disk_space)}, solid_band: {web: number_to_human_size(@web_bandwidth),ftp: number_to_human_size(@ftp_bandwidth)}})

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

      def get_solid_cp_used_space
        SolidCp::Package.new(user).get_package_diskspace
        # get_package_context
      end

      def get_solid_cp_used_bandwidth
        SolidCp::Package.new(user).get_package_bandwidth
      end

      def existing_quota
        QuotaUsage.where(user_id: user.id,product_id: product_id).first
      end

      def convert_to_json(resource ={})
        quota_hash = {
          # domains: resource[:domain][:count].presence || 0,
          # mailbox: resource[:mail][:count].presence || 0,
          # database: resource[:database][:count].presence || 0,
          ispconfig: {
            disk_space: {web: resource[:isp_disk][:web], mail: resource[:isp_disk][:mail], database: resource[:isp_disk][:database]},
            bandwidth: resource[:isp_bandwidth]
          },
          solidcp: {
            disk_space: {web: resource[:solid_disk][:web], file: resource[:solid_disk][:file], database: resource[:solid_disk][:database]},
            bandwidth: {web: resource[:solid_band][:web],ftp: resource[:solid_band][:ftp]}
          }
        }
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
  
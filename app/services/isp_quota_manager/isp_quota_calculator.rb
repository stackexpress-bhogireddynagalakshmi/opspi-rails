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
          end

          if user.solid_cp_id.present?
            return if user.packages.first.try(:solid_cp_package_id).nil?

             # response.body[:get_package_diskspace_response][:get_package_diskspace_result][:diffgram][:new_data_set][:table][:diskspace_bytes]
            solid_cp_quota = get_solid_cp_used_quotas
            quota_array = solid_cp_quota.body[:get_package_context_response][:get_package_context_result][:quotas_array][:quota_value_info]
            @disk_space = quota_array.collect{ |x| x[:quota_used_value] if x[:quota_name] == 'OS.Diskspace'}
            @bandwidth = quota_array.collect{ |x| x[:quota_used_value] if x[:quota_name] == 'OS.Bandwidth'}
          end

          if user.isp_config_id.present? || user.solid_cp_id.present?
            if @domain_response[:success] && @mail_response[:success] && @database_response[:success]

              @domain    = get_quota_info(@domain_response[:response])
              @mail      = get_quota_info(@mail_response[:response])
              @database  = get_quota_info(@database_response[:response])

              @quota = convert_to_json({domain: @domain,mail: @mail,database: @database, solid_disk: @disk_space, solid_band: @bandwidth})
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
      
      def get_solid_cp_used_quotas
        SolidCp::Package.new(user).get_package_context
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
            disk_space: number_to_human_size([resource[:domain][:space],resource[:mail][:space],resource[:database][:space]].reduce([], :concat).inject(0, :+)),
            bandwidth: 0
          },
          solidcp: {
            disk_space: "#{solid_cp_quota_value(resource[:solid_disk])} MB",
            bandwidth: solid_cp_quota_value(resource[:solid_band])
          }
        }
      end

      def solid_cp_quota_value(value)
        value.nil? ? 0 : value.compact.first
      end
  
      def get_quota_info(quota_data)
        count = quota_data.count
        used_space = quota_data.collect { |x| x.used.to_i }
        return {count: count, space: used_space}
      end
  
      def get_domain_quota
        Rails.logger.info { "Domain quote called" }
        IspConfig::QuotaDashboard.new(user).domain_quota
      end

      def get_mail_quota
        Rails.logger.info { "Mail quote called" }
        IspConfig::QuotaDashboard.new(user).mail_quota
      end

      def get_database_quota
        Rails.logger.info { "Database quote called" }
        IspConfig::QuotaDashboard.new(user).database_quota
      end
  
      private
  
    end
  end
  
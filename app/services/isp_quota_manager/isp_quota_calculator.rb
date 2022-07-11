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
            domain_response   = get_domain_quota
            mail_response     = get_mail_quota
            database_response = get_database_quota

            if domain_response[:success] && mail_response[:success] && database_response[:success]

              domain    = get_quota_info(domain_response[:response])
              mail      = get_quota_info(mail_response[:response])
              database  = get_quota_info(database_response[:response])

              quota = convert_to_json({domain: domain,mail: mail,database: database})
              quota_usage_obj = QuotaUsage.new({
                                  user_id: user.id,
                                  product_id: product_id,
                                  quota_used: quota
                                })

              if existing_quota.blank?
                quota_usage_obj.save!
              else
                existing_quota.update(quota_used: quota)
              end
            end
          end
        end
      end

      def existing_quota
        QuotaUsage.where(user_id: user.id,product_id: product_id).first
      end

      def convert_to_json(resource ={})
        quota_hash = {
          domains: resource[:domain][:count],
          mailbox: resource[:mail][:count],
          database: resource[:database][:count],
          disk_space: number_to_human_size([resource[:domain][:space],resource[:mail][:space],resource[:database][:space]].reduce([], :concat).inject(0, :+))
        }
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
  
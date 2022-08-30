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
          @websites = []
          if user.isp_config_id.present? 
            @domain_response   = get_domain_quota
            website_quota = @domain_response[:response].collect{|x| [x[:domain],x[:used]]}
            @mail_response     = get_mail_quota
            @mail_quota = @mail_response[:response].collect{|x| [x[:email],x[:used]]}

            website_quota.each do |website|
              @mail_quota.each do |mail|
                if website.first == (mail.first.split('@')[1])
                  website << mail
                end
              end
              @websites << website
            end
            
            # @websites.each do |website|
            #   @usage_hash = {
            #     "#{website.first}": {
            #       disk_space:{
            #       web_linux: website[1],
            #       mailboxes: {
            #         "#{website[2].first}": website[2].last
            #       }
            #       }
            #     }
            #    }
            # end
            # @usage = @usage_hash
            # byebug
            @database_response = get_database_quota

            @web_traffic       = get_web_traffic
            @web_bandwidth     = @web_traffic[:response]
            @ftp_traffic       = get_ftp_traffic
            @ftp_bandwidth     = @ftp_traffic[:response]
            ## mail
            
          end
        end
      end
      private

      def convert_to_hash(website)
       usage_hash = { usage: {
        "#{website.first}": {
          disk_space:{
          web_linux: website.last
          }
        }
       }
      }
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

      def convert_to_json(resource ={})
        quota_hash = {
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
  
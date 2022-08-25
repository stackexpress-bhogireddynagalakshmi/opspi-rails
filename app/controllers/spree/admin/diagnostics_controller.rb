# frozen_string_literal: true

module Spree
  module Admin
    # Diagnostics controller
    class DiagnosticsController < Spree::Admin::BaseController
      def index
        @diagnostics_hash = {}.with_indifferent_access
        common_checks
      end

      private

      def common_checks
        check_db_connection
        panel_ids = PanelConfig.pluck(:panel_id).uniq

        panel_ids.each do |panel_id|
          check_panel_connection(panel_id)
        end

        check_superadmin_payment_method(current_spree_user)
      end

      def check_db_connection
        begin
          ActiveRecord::Base.establish_connection # Establishes connection
          ActiveRecord::Base.connection # Calls connection object
          label = 'DB Connection'
          
          @diagnostics_hash[:database] =  { check_passed: ActiveRecord::Base.connected?, message: 'Connected', label: label}
        rescue => e
          @diagnostics_hash[:database] =  { check_passed: false, message: e.message, message: 'Failed to Connect', label: label}
        end
      end

      def check_panel_connection(panel_id)
        begin
          panel = Panel.find(panel_id)
          response = RemotePanelPing.new(panel_id).call
          @diagnostics_hash[panel_id] =  { check_passed: response[:success], message: response[:message], label:  panel.abbr}
          
        rescue Exception => e
          Rails.logger.error { e.backtrace }
          @diagnostics_hash[panel_id] =  { check_passed: false, message: "Panel not responding", label: panel.abbr}
        end
      end

      def check_superadmin_payment_method(user)
        pms = Spree::PaymentMethod.where(account_id: user.account_id)

        @diagnostics_hash[:payment_method] = {label: 'Superadmin Store Payment Methods', check_passed: pms.any?,   message: pms.any? ? "#{pms.count} Payment Methods exists" : 'Payment Methods does not exists' }        
      end
    end
  end
end


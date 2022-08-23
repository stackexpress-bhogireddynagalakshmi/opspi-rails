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
        check_isp_config_connection
        check_solid_cp_connection
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

      def check_isp_config_connection
        begin
          label = 'ISP Connection'
          response = current_spree_user.isp_config.ping

          @diagnostics_hash[:isp_config] =  { check_passed: response[:success], message: response[:message], label: label }
        rescue => e
          @diagnostics_hash[:isp_config] =  { check_passed: false, message: e.message, label: label}
        end
      end

      def check_solid_cp_connection
        begin
          label = 'Solid CP Connection'
          response = current_spree_user.solid_cp.ping
          @diagnostics_hash[:solid_cp] =  { check_passed: response[:success], message: response[:message], label: label }
        rescue => e
          @diagnostics_hash[:solid_cp] =  { check_passed: false, message: e.message, label: label}
        end
      end

      def check_superadmin_payment_method(user)
        pms = Spree::PaymentMethod.where(account_id: user.account_id)

        @diagnostics_hash[:payment_method] = {label: 'Superadmin Store Payment Methods', check_passed: pms.any?,   message: pms.any? ? "#{pms.count} Payment Methods exists" : 'Payment Methods does not exists' }        
      end
    end
  end
end


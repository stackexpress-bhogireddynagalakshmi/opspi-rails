# frozen_string_literal: true

module Spree
  module Admin
    # Diagnostics controller
    class DiagnosticsController < Spree::Admin::BaseController
      def index
        @diagnostics_hash = {}.with_indifferent_access
        configuration_checks_for(current_spree_user)
      end

      private

      def configuration_checks_for(user)
        check_db_connection
        panel_ids = PanelConfig.pluck(:panel_id).uniq

        if user.superadmin?
          # for superadmin check all the panels
          panel_ids.each do |panel_id|
            check_panel_connection(panel_id)
          end

          check_superadmin_payment_method(user)
        elsif user.store_admin?

          # for reseller check thier respective panel on which they are signed up
          linux_panel_id = user.panel_config["dns"]

          windows_panel_id = user.panel_config["web_windows"]

          check_panel_connection(linux_panel_id)

          check_panel_connection(windows_panel_id)

          check_reseller_club_setup(user)

          check_account_exist_on_remote_panels(user)

          check_superadmin_payment_method(user)

        elsif user.end_user?

          check_account_exist_on_remote_panels(user)
        end
      end

      def check_db_connection
        ActiveRecord::Base.establish_connection # Establishes connection
        ActiveRecord::Base.connection # Calls connection object
        label = 'DB Connection'

        @diagnostics_hash[:database] =
          { check_passed: ActiveRecord::Base.connected?, message: I18n.t(:connected), label: label }
      rescue StandardError => e
        @diagnostics_hash[:database] =
          { check_passed: false, message: e.message, message: I18n.t(:failed_to_connect), label: label }
      end

      def check_panel_connection(panel_id)
        panel = Panel.find(panel_id)
        response = RemotePanelPing.new(panel_id).call
        @diagnostics_hash[panel_id] =
          { check_passed: response[:success], message: response[:message], label: panel.abbr }
      rescue Exception => e
        Rails.logger.error { e.backtrace }
        @diagnostics_hash[panel_id] = { check_passed: false, message: I18n.t(:panel_not_responding), label: panel.abbr }
      end

      def check_superadmin_payment_method(user)
        pms = Spree::PaymentMethod.where(account_id: user.account_id)

        @diagnostics_hash[:payment_method] =
          { label: 'Store Payment Methods', check_passed: pms.any?,
            message: pms.any? ? "#{pms.count} Payment Methods exists" : 'Payment Methods does not exists' }
      end

      def check_reseller_club_setup(user)
        if user.account.reseller_club_configured?
          @diagnostics_hash[:reseller_club] =
            { label: I18n.t(:reseller_club), check_passed: true, message: I18n.t(:reseller_club_configured) }
        else
          @diagnostics_hash[:reseller_club] =
            { label: I18n.t(:reseller_club), check_passed: false, message: I18n.t(:reseller_club_not_configured) }
        end
      end

      def check_account_exist_on_remote_panels(user)
        label = "User Account for panel id: #{user.panel_config['dns']}"
        if user.isp_config_id.present?
          @diagnostics_hash[:isp_config_account] = { label: label, check_passed: true, message: I18n.t(:account_exist) }
        else
          @diagnostics_hash[:isp_config_account] =
            { label: label, check_passed: false, message: I18n.t(:account_does_not_exist) }
        end

        label = "User Account for panel id: #{user.panel_config['web_windows']}"
        if user.solid_cp_id.present?
          @diagnostics_hash[:solid_cp_account] = { label: label, check_passed: true, message: I18n.t(:account_exist) }
        else
          @diagnostics_hash[:solid_cp_account] =
            { label: label, check_passed: false, message: I18n.t(:account_does_not_exist) }
        end

        label = "Hosting space for panel id: #{user.panel_config['web_windows']}"
        if user.packages.any?
          @diagnostics_hash[:solid_cp_hosting_space] =
            { label: label, check_passed: true, message: I18n.t(:hosting_space_exists) }
        else
          @diagnostics_hash[:solid_cp_hosting_space] =
            { label: label, check_passed: false, message: I18n.t(:hosting_space_does_exists) }
        end
      end
    end
  end
end

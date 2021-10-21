module AppManager
  class PanelAccessEnabler  < ApplicationService
    attr_reader :invoice, :user

    def initialize(invoice,options = {})
      @user    = invoice.user
      @invoice = invoice
    end

    def call
      Rails.logger.info { "PanelAccessEnabler is called " }

      return unless invoice.present?
      return unless invoice.subscription.present?

      if invoice.subscription.plan.windows?
        response  = user.solidcp.change_user_status('Active')
        if response && response[:success] == true
          Rails.logger.info { "SolidCP account activated for #{invoice.user.email}" }

          invoice.subscription.update_column(:panel_disabled_at,nil)
          send_panel_access_enabled_notification('SolidCP')
        else
          Rails.logger.info { "Unable to activated SolidCP account" }
        end

      elsif invoice.subscription.plan.linux?
        response = user.isp_config.enable_client_login

        if response && response[:success] == true
          Rails.logger.info { "ISPConfig account suspended for #{invoice.user.email}" }

          invoice.subscription.update_column(:panel_disabled_at,nil)
          send_panel_access_enabled_notification('ISPConfig')
        else
          Rails.logger.info { "Unable to activated ISPConfig account for #{invoice.user.email}" }
        end

      else
        raise StandardError.new 'Subscription Pannel not supported #{invoice.subscription.plan.try(:server_type)}'
      end  
    end

    private

     def send_panel_access_enabled_notification(panel)
      args = {
          invoice: invoice,
          notification: 'pannel_access_enabled',
          user: invoice.user,
          panel: panel
        }

      AppManager::NotificationManager.new(args).call
    end


  end
end
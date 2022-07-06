module AppManager
  class PanelAccessDisabler  < ApplicationService
    attr_reader :invoice, :user

    def initialize(invoice,options = {})
      @user    = invoice.user
      @invoice = invoice
    end

    def call
      Rails.logger.info { "PanelAccessDisabler is called " }

      return unless invoice.present?
      return unless invoice.subscription.present?

      if invoice.subscription.plan.windows?
        response  = user.solid_cp.change_user_status('Suspended')
        if response && response[:success] == true
          Rails.logger.info { "SolidCP account suspended for #{invoice.user.email}" }
          invoice.subscription.update_column(:panel_disabled_at,Time.zone.now)
          invoice.subscription.update({status: false})
          send_panel_access_disabled_notification('SolidCP')
        else
          Rails.logger.info { "Unable to suspend SolidCP account" }
        end

      elsif invoice.subscription.plan.linux?
        response = user.isp_config.disable_client_login
        if response && response[:success] == true
          Rails.logger.info { "ISPConfig account suspended for #{invoice.user.email}" }

          invoice.subscription.update_column(:panel_disabled_at,Time.zone.now)
          invoice.subscription.update({status: false})
          send_panel_access_disabled_notification('ISPConfig')
        else
          Rails.logger.info { "Unable to suspend ISPConfig account for #{invoice.user.email}" }
        end

      elsif invoice.subscription.plan.hsphere?

      else
        raise StandardError.new 'Subscription Panel not supported #{invoice.subscription.plan.try(:server_type)}'
      end  
    end

    private

     def send_panel_access_disabled_notification(panel)
      args = {
          invoice: invoice,
          notification: 'pannel_access_disabled',
          user: invoice.user,
          panel: panel
        }

      AppManager::NotificationManager.new(args).call
    end


  end
end
module AppManager
  class AccountProvisioner
    
    attr_reader :user,:product,:order

      def initialize(user,options = {})
        @user = user
        @product = options[:product]
        @order = options[:order]
      end

      def call
        Rails.logger.info { "AccountProvisioner is called " }
        provison_solid_cp_account
        provision_isp_config_account
      end

      def provison_solid_cp_account
        Rails.logger.info { "provison_solid_cp_account is called " }

        if panels_access('solid_cp') 
          SolidCpProvisioningJob.set(wait: 3.second).perform_later(user.id,product&.id) 
          Rails.logger.info { "SolidCpProvisioningJob is scheduled to create user account on solid CP " }
        end

      end

      def provision_isp_config_account
        Rails.logger.info { "provision_isp_config_account is called " }

        if panels_access('isp_config')
          IspConfigProvisioningJob.set(wait: 3.second).perform_later(user.id,order&.subscribable_product&.id)
          Rails.logger.info { "IspConfigProvisioningJob is scheduled to create user account on ISPConfig Account " }
        end
      end

      private

      def panels_access(panel)
        @panels = []
          if order.present?        
              order.line_items.each do |line_item|
                next if line_item.product.blank?
                panel_name = line_item.product.windows? ? 'solid_cp' : 'isp_config' 
                 @panels << panel_name  if !@panels.include?(panel)
            end
          end
          @panels.include?(panel)
      end

  end
end
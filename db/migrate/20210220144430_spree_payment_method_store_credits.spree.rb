# This migration comes from spree (originally 20150714154102)
class SpreePaymentMethodStoreCredits < ActiveRecord::Migration[4.2]
  def up
    begin
      # Reload to pick up new position column for acts_as_list
      Spree::PaymentMethod.reset_column_information
      Spree::PaymentMethod::StoreCredit.find_or_create_by(name: 'Store Credit', description: 'Store Credit',
                                                        active: true, display_on: 'back_end')
    rescue Exception => e
      Rails.logger.info { "Migration error for PaymentMethod: #{e.message}"}        
    end

  end

  def down
    Spree::PaymentMethod.find_by(type: 'Spree::PaymentMethod::StoreCredit', name: 'Store Credit').try(&:destroy)
  end
end

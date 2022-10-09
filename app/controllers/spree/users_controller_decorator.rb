# frozen_string_literal: true

module Spree
  module UsersControllerDecorator

    def self.prepended(base)
      base.skip_before_action :load_object
      base.before_action :load_object
    end

    def show
      super
      @orders = TenantManager::TenantHelper.unscoped_query { @user.orders.order('created_at desc') }
      @invoices = TenantManager::TenantHelper.unscoped_query { @user.invoices.order(created_at: :desc) }

      if current_spree_user.invoices.active.count > 0
        flash[:warning] =  Spree.t('pending_invoices')
      end
    end
  end
end

if ::Spree::UsersController.included_modules.exclude?(::Spree::UsersControllerDecorator)
  ::Spree::UsersController.prepend ::Spree::UsersControllerDecorator
end

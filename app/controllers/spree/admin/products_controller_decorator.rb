# frozen_string_literal: true

module Spree
  module Admin
    module ProductsControllerDecorator
      include ApplicationHelper

      def self.prepended(base)
        base.before_action :ensure_user_confirmed, except: [:show, :index, :new]
        base.after_action :create_product_config, only: [:create]
      end


      def collection
        @collection = super
        @collection = @collection.where(account_id: current_spree_user.account_id) rescue []
      end

      protected
      def location_after_save
        params.key?(:done) ? admin_products_path : edit_admin_product_url(@product)
      end

      def create_product_config
        AppManager::ProductConfigCreator.new(@product,params).call
      end
    end
  end
end

if ::Spree::Admin::ProductsController.included_modules.exclude?(Spree::Admin::ProductsControllerDecorator)
  ::Spree::Admin::ProductsController.prepend Spree::Admin::ProductsControllerDecorator
end


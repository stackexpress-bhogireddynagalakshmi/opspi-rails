# frozen_string_literal: true

module Spree
  module Admin
    class MyStoreController < Spree::Admin::BaseController
      helper Spree::Admin::NavigationHelper
      require 'store_domain_validator'

      def index
        @store = current_store
      end

      def update
        @store = current_store
        if params[:custom_domain].present?
          response = validate_custom_domian(params[:custom_domain])
          if response[:success]
            @store.update(store_params)
            @store.url = params[:custom_domain]
            @store.save
            flash[:success] = flash_message_for(@store, :successfully_updated)
          else
            @store.errors.add(:url, response[:msg])
          end
        else
          @store.update(store_params)
          flash[:success] = flash_message_for(@store, :successfully_updated)
        end
        render "index"
      end

      def show
        redirect_to action: :index
      end

      def validate_domain
        response = validate_custom_domian(params[:custom_domain])

        render json: response
      end

      private

      def store_params
        params.require(:store).permit(:logo, :mailer_logo, :name, :seo_title, :meta_description, :meta_keywords, :seo_robots,
                                      :description, :address, :contact_phone, :mail_from_address, :customer_support_email, :new_order_notifications_email)
      end

      def validate_custom_domian(custom_domain)
        return { success: false, msg: I18n.t('my_store.domain_cannot_be_blank') } if custom_domain.blank?

        validation = StoreDomainValidator.new(custom_domain, current_store: current_store).call
        return { success: false, msg: validation[1] } unless validation[0]

        dns_resolver = DnsManager::CnameResolver.new(custom_domain).call
        unless dns_resolver.cname_configured?
          return { success: false,
                   msg: I18n.t('my_store.cname_not_added', cname: ENV['CNAME_POINTER_DOMAIN'], custom_domain: custom_domain).html_safe, current_cname: dns_resolver.cname }
        end

        { success: true, msg: I18n.t('my_store.domain_validated') }
      end
    end
  end
end

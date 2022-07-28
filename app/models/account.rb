# frozen_string_literal: true

class Account < ApplicationRecord
  has_one :spree_store, class_name: 'Spree::Store'
  has_many :spree_products, class_name: 'Spree::Product', dependent: :destroy
  has_many :spree_orders, class_name: 'Spree::Order', dependent: :destroy
  has_many :users, class_name: 'Spree::User', dependent: :destroy
  has_many :payment_methods, class_name: 'Spree::PaymentMethod'
  has_many :prototypes,  class_name: 'Spree::Prototype'

  scope :by_subdomain, lambda { |url|
    where(subdomain: url)
  }

  def store_admin
    users.select(&:store_admin?).first
  end

  def admin_tenant?
    TenantManager::TenantHelper.admin_tenant.id == id
  end

  def reseller_club_configured?
    store_admin.user_key.present? && store_admin.user_key.reseller_club_account_id.present? && store_admin.user_key.reseller_club_account_key_enc.present?
  end
end
